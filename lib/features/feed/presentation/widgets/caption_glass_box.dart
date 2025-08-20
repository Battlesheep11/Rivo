import 'package:flutter/material.dart';

class CaptionGlassBox extends StatelessWidget {
  final String title;            // product title
  final String seller;           // username
  final String price;            // formatted price text (e.g., ₪120)
  final double height;           // box height
  final String? caption;         // OPTIONAL: post caption
  final VoidCallback? onUsernameTap;

  const CaptionGlassBox({
    super.key,
    required this.title,
    required this.seller,
    required this.price,
    required this.height,
    this.caption,
    this.onUsernameTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        // remove `const` to avoid const-eval complaints
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0x00000000), // transparent
              Color(0xB8000000), // 72% black
            ],
            stops: [0.0, 0.8],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title (product title)
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  height: 1.2,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (caption != null && caption!.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  caption!.trim(),
                  style: const TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    height: 1.3,
                    color: Color(0xE6FFFFFF),
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 8),
              // Seller (tap to profile)
              GestureDetector(
                onTap: onUsernameTap,
                child: Text(
                  'By $seller', // TODO: localize "By"
                  style: const TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    height: 1.3,
                    color: Color(0xE6FFFFFF),
                    letterSpacing: -0.3,
                  ),
                ),
              ),

              const SizedBox(height: 8),
              // Price
              Text(
                price,
                style: const TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  height: 1.0,
                  color: Color(0xE6FFFFFF),
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
