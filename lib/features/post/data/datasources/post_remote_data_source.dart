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

      String? productId;
      String postId = '';

      if (payload.hasProduct) {
        productId = await _uploadProduct(
          payload,
          userId,
          onMediaUploaded,
          onMediaStatusChanged,
        );
      }

      postId = await _uploadFeedPost(payload, userId, productId);
      return postId;
    } on PostgrestException catch (e) {
      throw AppException.unexpected(
        'Supabase error: ${e.message}',
        code: 'upload_post_error',
      );
    } catch (e) {
      throw AppException.unexpected(
        'Unexpected error occurred',
        code: 'upload_post_error',
      );
    }
  }

  Future<String> _uploadProduct(
    UploadPostPayload payload,
    String userId,
    void Function(int uploaded, int total)? onMediaUploaded,
    void Function(String mediaPath, UploadMediaStatus status)? onMediaStatusChanged,
  ) async {
    log('🔄 Attempting to insert product with category ID: ${payload.categoryId}');
    log('📝 Category ID type: ${payload.categoryId.runtimeType}');
    
    final productResponse = await client
        .from('products')
        .insert({
          'seller_id': userId,
          'title': payload.productTitle,
          'description': payload.productDescription,
          'price': payload.productPrice,
          'chest': payload.chest,
          'waist': payload.waist,
          'length': payload.length,
          'category_id': payload.categoryId,
        })
        .select('id')
        .single();
        
    log('✅ Product inserted with ID: ${productResponse['id']}');

    final productId = productResponse['id'] as String;

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
              'media_type': media.type.name,
            })
            .select('id')
            .single();

        final mediaId = mediaInsert['id'] as String;

        await client.from('product_media').insert({
          'product_id': productId,
          'media_id': mediaId,
          'sort_order': media.sortOrder ?? 0,
        });

        onMediaUploaded?.call(i + 1, payload.media.length);
        onMediaStatusChanged?.call(media.path, UploadMediaStatus.uploaded);
      } catch (e) {
        onMediaStatusChanged?.call(media.path, UploadMediaStatus.failed);
        continue;
      }
    }

    // Tags
    for (final tag in payload.tags) {
      final tagId = await _getOrCreateTagByName(tag.name);
      await client.from('product_tags').insert({
        'product_id': productId,
        'tag_id': tagId,
      });
    }

    return productId;
  }

  Future<File> _prepareFileForUpload({
    required UploadableMedia media,
    required void Function(String mediaPath, UploadMediaStatus status)? onMediaStatusChanged,
  }) async {
    File? file = media.file ?? await media.asset.file;
    if (file == null) {
      throw AppException.unexpected("Cannot access media file");
    }

    // Images: light compression
    if (media.type == MediaType.image) {
      onMediaStatusChanged?.call(media.path, UploadMediaStatus.compressing);
      final result = await MediaCompressor.compressImageFile(file, quality: 88); // ⬆️
      final prepared = result.fold<File>(
        (compressed) => compressed,
        (_) => file, // fallback to original if compression failed
      );
      onMediaStatusChanged?.call(media.path, UploadMediaStatus.compressed);
      return prepared;
    }

    // Videos: skip tiny files (<8MB) to save time/battery, otherwise compress
    final originalSize = await file.length();
    const skipThresholdBytes = 12 * 1024 * 1024;

    if (originalSize <= skipThresholdBytes) {
      return file;
    }

    onMediaStatusChanged?.call(media.path, UploadMediaStatus.compressing);
    final vResult = await MediaCompressor.compressVideoFile(file);
    final prepared = vResult.fold<File>(
      (compressed) => compressed,
      (_) => file, // fallback to original if compression fails
    );
    onMediaStatusChanged?.call(media.path, UploadMediaStatus.compressed);
    return prepared;
  }

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


  // === Option A: upload a single media item under a session prefix ===
  // Path: media bucket → {userId}/{sessionId}/{index}.jpg|mp4
  // Returns the filename (e.g., "0.jpg") so the caller can build `expectedFiles` in order.
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

    // Reuse existing compression/validation logic
    final preparedFile = await _prepareFileForUpload(
      media: media,
      onMediaStatusChanged: onMediaStatusChanged,
    );

    // Determine deterministic filename by index (stable ordering for finalize_post)
    final String filename = _sessionFilename(media, index);

    // IMPORTANT: path is RELATIVE to the 'media' bucket (no 'media/' prefix here)
    final relativePath = '${user.id}/$sessionId/$filename';

    // Upload
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

  // Helper: stable filename for session uploads
  static String _sessionFilename(UploadableMedia media, int index) {
    final ext = media.type == MediaType.video ? 'mp4' : 'jpg';
    return '$index.$ext';
  }

    /// Starts a lean upload session:
  /// 1) Creates the product (draft) for the current user.
  /// 2) Returns a new sessionId (uuid) and the productId.
  ///
  /// Media uploads should then call `uploadMediaToSession(...)` using this sessionId.
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
          'category_id': payload.categoryId,
        })
        .select('id')
        .single();

    final productId = productResp['id'] as String;
    final sessionId = const Uuid().v4();

    return (sessionId: sessionId, productId: productId);
  }

  /// Finalizes the post by calling the `finalize_post` Edge Function.
  /// - If some files are still missing in Storage, the function returns 202/pending.
  ///   In that case we throw an AppException with code 'finalize_pending' so the caller can retry.
  /// - On success returns the created postId.
  Future<String> finalizePostSession({
    required String sessionId,
    required String productId,
    required String? caption,
    required List<String> tagNames,
    required List<String> expectedFiles, // MUST be in the same order used for filenames
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

    // Handle "pending" (some files not uploaded yet)
    final status = res.status; // present in supabase_dart v2
    if (status == 202) {
      throw AppException.unexpected('finalize_pending', code: 'finalize_pending');
    }

    // Extra safety if the function encodes status in data
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
  /// Discards an in-progress session:
  /// - Deletes all files under {userId}/{sessionId}/ in the `media` bucket.
  /// - Optionally deletes the draft product if it's not linked to any post.
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

  /// End-to-end upload using the lean Option A flow:
  /// 1) Creates a product + sessionId.
  /// 2) For each media: prepare (compress/validate) and upload to storage under {userId}/{sessionId}/{index}.ext
  /// 3) Finalizes via Edge Function `finalize_post` with retry if files are still pending.
  ///
  /// Returns the created postId on success.
  Future<String> uploadPostOptionA(
    UploadPostPayload payload, {
    void Function(int uploaded, int total)? onMediaUploaded,
    void Function(String mediaPath, UploadMediaStatus status)? onMediaStatusChanged,
    Duration retryEvery = const Duration(seconds: 2),
    int maxFinalizeAttempts = 20, // ~40s
  }) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw AppException.unauthorized('User not logged in');
    }

    // 1) Start: create product & get sessionId
    final start = await startUploadSession(payload);
    final sessionId = start.sessionId;
    final productId = start.productId;

    // 2) Upload each media immediately (order matters)
    final expectedFiles = <String>[];
    for (int i = 0; i < payload.media.length; i++) {
      final media = payload.media[i];

      // Reuse the single-item session upload we added earlier
      final filename = await uploadMediaToSession(
        sessionId: sessionId,
        media: media,
        index: i,
        onMediaStatusChanged: onMediaStatusChanged,
      );
      expectedFiles.add(filename);

      onMediaUploaded?.call(i + 1, payload.media.length);
    }

    // 3) Finalize with retry (handles "pending" 202 from Edge Function)
    AppException? lastErr;
    for (int attempt = 0; attempt < maxFinalizeAttempts; attempt++) {
      try {
        final postId = await finalizePostSession(
          sessionId: sessionId,
          productId: productId,
          caption: payload.caption,
          tagNames: payload.tags.map((t) => t.name).toList(),
          expectedFiles: expectedFiles,
        );
        return postId; // ✅ done
      } on AppException catch (e) {
        // Function returns 202 → we encode as 'finalize_pending'
        if (e.code == 'finalize_pending') {
          await Future.delayed(retryEvery);
          lastErr = e;
          continue;
        }
        // Any other error = fail fast
        rethrow;
      }
    }

    // If we get here, finalize timed out
    throw lastErr ?? AppException.unexpected('finalize_timeout', code: 'finalize_timeout');
  }


}
