import 'package:flutter/material.dart';
import 'package:rivo_app_beta/design_system/exports.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/features/discovery/domain/entities/discovery_product_entity.dart';

class FeaturedProductCard extends StatelessWidget {
  final DiscoveryProductEntity product;
  final VoidCallback? onTap;

  const FeaturedProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FeaturedCardBase(
      imageUrl: product.imageUrl,
      onTap: onTap,
      overlay: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280), // 👈 מגבלה גלובלית לרוחב
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
    children: [
      // תגית עליונה
      Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: const Color(0xFF5B21B6), // סגול כהה #5b21b6
    borderRadius: BorderRadius.circular(999), // FULLY rounded
    boxShadow: [
      BoxShadow(
        color: Colors.black.withAlpha((0.05 * 255).round()),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ],
  ),
  child: Text(
    AppLocalizations.of(context)!.pickOfTheDay,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      // textTransform: uppercase לא נדרש – כבר בא מרשימת מחרוזות
    ),
  ),
),

      const SizedBox(height: 12),

      GlassText(
        text: product.title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
      ),
      const SizedBox(height: 8),

      Text(
  product.description,
  style: const TextStyle(
    color: Color(0xFFF3F4F6), // טקסט לבן-בהיר
    fontSize: 14,
    height: 1.6, // שווה ל־line-height / font-size
    fontWeight: FontWeight.w400,
  ),
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
),

      const SizedBox(height: 16),
      Container(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha((0.15 * 255).round()),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white30),
        ),
        
        child: AppButton(
  onPressed: onTap ?? () {},
  variant: AppButtonVariant.overlay,
  // label: '', ← אל תעביר!
  child: Row(
    mainAxisSize: MainAxisSize.min,
    textDirection: Directionality.of(context),
    children: [
      Text(
        AppLocalizations.of(context)!.explore,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(width: 8),
      const Icon(Icons.arrow_forward, size: 18),
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
