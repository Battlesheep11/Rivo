import 'package:flutter/material.dart';

class FeaturedCardBase extends StatelessWidget {
  final String imageUrl;
  final Widget overlay;
  final VoidCallback? onTap;
  final double borderRadius;
  final double aspectRatio;

  const FeaturedCardBase({
    super.key,
    required this.imageUrl,
    required this.overlay,
    this.onTap,
    this.borderRadius = 28,
    this.aspectRatio = 3 / 3.4,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha((0.7 * 255).round()),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      overlay,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
