import 'package:flutter/material.dart';
import 'package:rivo_app_beta/features/discovery/domain/entities/curated_collection_entity.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/design_system/exports.dart'; // ✅ Barrel import

class CuratedCollectionCard extends StatelessWidget {
  final CuratedCollectionEntity collection;
  final VoidCallback? onTap;

  const CuratedCollectionCard({
    super.key,
    required this.collection,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ✅ תמונת רקע
            Image.network(
              collection.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const ColoredBox(
                color: Colors.grey,
                child: Center(
                  child: Icon(Icons.image, size: 32, color: Colors.white),
                ),
              ),
            ),

            // ✅ גרדיאנט כהה בתחתית
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withAlpha((0.5 * 255).round()),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),

            // ✅ תוכן טקסטי
            Align(
              alignment: AlignmentDirectional.bottomStart,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔤 שם האוסף
                    Text(
                      collection.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        shadows: [
                          Shadow(color: Colors.black26, blurRadius: 4),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // 🧩 שורת פריטים + אייקון SVG
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (collection.iconUrl != null) ...[
                          AppSvgIcon(
                            url: collection.iconUrl!,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          '${collection.postCount} ${AppLocalizations.of(context)!.items}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
