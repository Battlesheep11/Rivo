import 'dart:developer';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app_beta/core/error_handling/app_exception.dart';
import 'package:rivo_app_beta/features/post/domain/entities/upload_post_payload.dart';
import 'package:rivo_app_beta/core/media/domain/entities/uploadable_media.dart';
import 'package:rivo_app_beta/core/media/data/media_compressor.dart';
import 'package:rivo_app_beta/core/constants/media_constraints.dart';
import 'package:uuid/uuid.dart';

class PostRemoteDataSource {
  final SupabaseClient client;

  PostRemoteDataSource({required this.client});

  /// End-to-end upload (Product → media → post → tags + product_* M:N joins)
    Future<String> uploadPost(
    UploadPostPayload payload, {
    void Function(int uploaded, int total)? onMediaUploaded,
    void Function(String mediaPath, UploadMediaStatus status)? onMediaStatusChanged,
  }) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        throw AppException.unauthorized('User not logged in');
      }

      // Thin safety net (server-side rules)
      if ((payload.productPrice ?? 0) <= 1) {
        throw AppException.validation('uploadPriceRequiredBackend');
      }
      if (payload.productTitle == null || payload.productTitle!.trim().isEmpty) {
        throw AppException.validation('uploadTitleRequiredBackend');
      }
      if ((payload.conditionCode ?? '').isEmpty) {
        throw AppException.validation('upload.required_fields_missing');
      }
      if ((payload.conditionCode == 'good' || payload.conditionCode == 'fair') &&
          ((payload.defectCodes == null) || payload.defectCodes!.isEmpty)) {
        throw AppException.validation('defects_required_for_condition');
      }

      // Helpful diagnostics
      log('[PAYLOAD] title=${payload.productTitle} '
          'price=${payload.productPrice} '
          'category=${payload.categoryId} '
          'condition=${payload.conditionCode} '
          'defects=${payload.defectCodes} '
          'materials=${payload.materialCodes} '
          'colors=${payload.colorCodes}');

      String? productId;
      if (payload.hasProduct) {
        productId = await _uploadProduct(
          payload,
          userId,
          onMediaUploaded,
          onMediaStatusChanged,
        );
      }

      final postId = await _uploadFeedPost(payload, userId, productId);
      return postId;

    } on PostgrestException catch (e, st) {
      log('❌ PostgrestException', error: e, stackTrace: st);
      throw AppException.unexpected('Supabase DB error: ${e.message}', code: 'postgrest_error');
    } on StorageException catch (e, st) {
      log('❌ StorageException', error: e, stackTrace: st);
      throw AppException.unexpected('Storage error: ${e.message}', code: 'storage_error');
    } on AppException {
      rethrow; // already structured for UI
    } catch (e, st) {
      log('🔥 Unexpected error in uploadPost', error: e, stackTrace: st);
      throw AppException.unexpected(e.toString(), code: 'unexpected_upload');
    }
  }


  // --------------------------------------------------------------------------
  // Product creation + media + schema-aligned M:N joins (defects/materials/colors)
  // --------------------------------------------------------------------------
  Future<String> _uploadProduct(
    UploadPostPayload payload,
    String userId,
    void Function(int uploaded, int total)? onMediaUploaded,
    void Function(String mediaPath, UploadMediaStatus status)? onMediaStatusChanged,
  ) async {
    log('🔄 Inserting product; category ID: ${payload.categoryId} (${payload.categoryId.runtimeType})');

    // Insert product with new columns aligned to schema
    final productResponse = await client
        .from('products')
        .insert({
          'seller_id': userId,
          'title': payload.productTitle,
          'description': payload.productDescription,
          'price': payload.productPrice,
          'category_id': payload.categoryId,
          // Measurements
          'chest': payload.chest,
          'waist': payload.waist,
          'length': payload.length,
          'sleeve_length': payload.sleeveLength,
          'shoulder_width': payload.shoulderWidth,
          // Brand / Size
          'brand': payload.brand,
          'size': payload.size,
          // Condition code (schema-aligned)
          'condition_code': payload.conditionCode,
          // NOTE: materials/colors are saved via join tables (below)
        })
        .select('id')
        .single();

    final productId = productResponse['id'] as String;
    log('✅ Product inserted: $productId');

    // ---- M:N joins: product_defects / product_materials / product_colors ----
    final List<String> defects   = payload.defectCodes   ?? const <String>[];
    final List<String> materials = payload.materialCodes ?? const <String>[];
    final List<String> colors    = payload.colorCodes    ?? const <String>[];

    // ---- M:N joins: product_defects / product_materials / product_colors ----
   // product_defects
if (defects.isNotEmpty) {
  final List<Map<String, dynamic>> defectRows = defects
      .map((code) => {
            'product_id': productId,
            'defect_code': code,
          })
      .toList();
  await client.from('product_defects').insert(defectRows);
}

// product_materials
if (materials.isNotEmpty) {
  final List<Map<String, dynamic>> materialRows = materials
      .map((code) => {
            'product_id': productId,
            'material_code': code,
          })
      .toList();
  await client.from('product_materials').insert(materialRows);
}

// product_colors
if (colors.isNotEmpty) {
  final List<Map<String, dynamic>> colorRows = colors
      .map((code) => {
            'product_id': productId,
            'color_code': code,
          })
      .toList();
  await client.from('product_colors').insert(colorRows);
}


    // ---- Media upload (order preserved via sort_order; cover should be index 0) ----
    for (int i = 0; i < payload.media.length; i++) {
      final media = payload.media[i];

      try {
        // Prepare (validate/compress) the file first
        final preparedFile = await _prepareFileForUpload(
          media: media,
          onMediaStatusChanged: onMediaStatusChanged,
        );

        // If video still exceeds limit post-compression → localized validation error
        if (media.type == MediaType.video) {
          final size = await preparedFile.length();
          if (size > MediaConstraints.maxVideoSizeInBytes) {
            final mb = (size / (1024 * 1024)).toStringAsFixed(1);
            final maxMb = (MediaConstraints.maxVideoSizeInBytes / (1024 * 1024)).toStringAsFixed(0);
            log('❌ Video too large after compression: $mb MB (limit: $maxMb MB)');
            throw AppException.validation('uploadVideoTooLargeBackend');
          }
        }

        // Start upload
        onMediaStatusChanged?.call(media.path, UploadMediaStatus.uploading);

        // Normalize extensions & content types
        final isVideo = media.type == MediaType.video;
        final ext = isVideo ? 'mp4' : 'jpg';
        final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
        final filename = '${userId}_$uniqueId.$ext';
        // NOTE: here we prefix with 'media/' because we use .from('media') and want a subfolder path
        final path = 'media/$filename';

        final fileBytes = await preparedFile.readAsBytes();

        await client.storage.from('media').uploadBinary(
          path,
          fileBytes,
          fileOptions: FileOptions(
            contentType: isVideo ? 'video/mp4' : 'image/jpeg',
            upsert: true,
          ),
        );

        final mediaUrl = client.storage.from('media').getPublicUrl(path);

        final mediaInsert = await client
            .from('media')
            .insert({
              'media_url': mediaUrl,
              'media_type': media.type.name, // 'image' | 'video' (enum)
            })
            .select('id')
            .single();

        final mediaId = mediaInsert['id'] as String;

        await client.from('product_media').insert({
          'product_id': productId,
          'media_id': mediaId,
          'sort_order': media.sortOrder ?? i,
        });

        onMediaUploaded?.call(i + 1, payload.media.length);
        onMediaStatusChanged?.call(media.path, UploadMediaStatus.uploaded);
      } catch (e) {
        onMediaStatusChanged?.call(media.path, UploadMediaStatus.failed);
        // continue to next media
        continue;
      }
    }

    // ---- Tags on product ----
    for (final tag in payload.tags) {
      final tagId = await _getOrCreateTagByName(tag.name);
      await client.from('product_tags').insert({
        'product_id': productId,
        'tag_id': tagId,
      });
    }

    return productId;
  }

  // --------------------------------------------------------------------------
  // Feed post + post tags
  // --------------------------------------------------------------------------
  Future<String> _uploadFeedPost(
    UploadPostPayload payload,
    String userId,
    String? productId,
  ) async {
    final postResponse = await client
        .from('feed_post')
        .insert({
          'creator_id': userId,
          'product_id': productId,
          'caption': payload.caption,
        })
        .select('id')
        .single();

    final postId = postResponse['id'] as String;

    for (final tag in payload.tags) {
      final tagId = await _getOrCreateTagByName(tag.name);
      await client.from('post_tags').insert({
        'post_id': postId,
        'tag_id': tagId,
      });
    }

    return postId;
  }

  Future<String> _getOrCreateTagByName(String tagName) async {
    final existing = await client
        .from('tags')
        .select('id')
        .eq('name', tagName)
        .maybeSingle();

    if (existing != null) {
      return existing['id'] as String;
    }

    final created = await client
        .from('tags')
        .insert({
          'name': tagName,
          'is_visible': true,
        })
        .select('id')
        .single();

    return created['id'] as String;
  }

  // --------------------------------------------------------------------------
  // Session-based Option A (unchanged, still available if you use the Edge Fn)
  // --------------------------------------------------------------------------

  Future<String> uploadMediaToSession({
    required String sessionId,
    required UploadableMedia media,
    required int index,
    void Function(String mediaPath, UploadMediaStatus status)? onMediaStatusChanged,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw AppException.unauthorized('User not logged in');
    }

    final preparedFile = await _prepareFileForUpload(
      media: media,
      onMediaStatusChanged: onMediaStatusChanged,
    );

    final String filename = _sessionFilename(media, index);
    final relativePath = '${user.id}/$sessionId/$filename';

    onMediaStatusChanged?.call(media.path, UploadMediaStatus.uploading);
    await client.storage.from('media').uploadBinary(
      relativePath,
      await preparedFile.readAsBytes(),
      fileOptions: FileOptions(
        contentType: media.type == MediaType.video ? 'video/mp4' : 'image/jpeg',
        upsert: true,
      ),
    );
    onMediaStatusChanged?.call(media.path, UploadMediaStatus.uploaded);

    return filename;
  }

  static String _sessionFilename(UploadableMedia media, int index) {
    final ext = media.type == MediaType.video ? 'mp4' : 'jpg';
    return '$index.$ext';
  }

  Future<({String sessionId, String productId})> startUploadSession(
    UploadPostPayload payload,
  ) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw AppException.unauthorized('User not logged in');
    }

    final productResp = await client
        .from('products')
        .insert({
          'seller_id': userId,
          'title': payload.productTitle,
          'description': payload.productDescription,
          'price': payload.productPrice,
          'chest': payload.chest,
          'waist': payload.waist,
          'length': payload.length,
          'sleeve_length': payload.sleeveLength,
          'shoulder_width': payload.shoulderWidth,
          'category_id': payload.categoryId,
          'brand': payload.brand,
          'size': payload.size,
          'condition_code': payload.conditionCode,
        })
        .select('id')
        .single();

    final productId = productResp['id'] as String;
    final sessionId = const Uuid().v4();

    return (sessionId: sessionId, productId: productId);
  }

  Future<String> finalizePostSession({
    required String sessionId,
    required String productId,
    required String? caption,
    required List<String> tagNames,
    required List<String> expectedFiles,
  }) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw AppException.unauthorized('User not logged in');
    }

    final res = await client.functions.invoke('finalize_post', body: {
      'session_id': sessionId,
      'product_id': productId,
      'caption': caption,
      'tags': tagNames,
      'expected_files': expectedFiles,
    });

    final status = res.status;
    if (status == 202) {
      throw AppException.unexpected('finalize_pending', code: 'finalize_pending');
    }

    final data = res.data;
    if (data is Map && data['status'] == 'pending') {
      throw AppException.unexpected('finalize_pending', code: 'finalize_pending');
    }

    final postId = (data is Map) ? data['post_id'] as String? : null;
    if (postId == null || postId.isEmpty) {
      throw AppException.unexpected('finalize_missing_post_id', code: 'finalize_missing_post_id');
    }
    return postId;
  }

  Future<void> discardUploadSession({
    required String sessionId,
    String? productId,
  }) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw AppException.unauthorized('User not logged in');
    }

    final res = await client.functions.invoke('discard_session', body: {
      'session_id': sessionId,
      if (productId != null) 'product_id': productId,
    });

    if (res.status != 200) {
      throw AppException.unexpected('discard_failed', code: 'discard_failed');
    }
  }

  // --------------------------------------------------------------------------
  // Shared helpers
  // --------------------------------------------------------------------------
  Future<File> _prepareFileForUpload({
    required UploadableMedia media,
    required void Function(String mediaPath, UploadMediaStatus status)? onMediaStatusChanged,
  }) async {
    File? file = media.file ?? await media.asset.file;
    if (file == null) {
      throw AppException.unexpected("Cannot access media file");
    }

    if (media.type == MediaType.image) {
      onMediaStatusChanged?.call(media.path, UploadMediaStatus.compressing);
      final result = await MediaCompressor.compressImageFile(file, quality: 88);
      final prepared = result.fold<File>(
        (compressed) => compressed,
        (_) => file,
      );
      onMediaStatusChanged?.call(media.path, UploadMediaStatus.compressed);
      return prepared;
    }

    final originalSize = await file.length();
    const skipThresholdBytes = 12 * 1024 * 1024;
    if (originalSize <= skipThresholdBytes) {
      return file;
    }

    onMediaStatusChanged?.call(media.path, UploadMediaStatus.compressing);
    final vResult = await MediaCompressor.compressVideoFile(file);
    final prepared = vResult.fold<File>(
      (compressed) => compressed,
      (_) => file,
    );
    onMediaStatusChanged?.call(media.path, UploadMediaStatus.compressed);
    return prepared;
  }
}
