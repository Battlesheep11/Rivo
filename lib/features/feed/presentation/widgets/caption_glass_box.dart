import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';

/// A reusable glass caption overlay for feed posts, with iOS-style liquid glass and gradient.
class CaptionGlassBox extends StatelessWidget {
  // Username to display at the top of the caption box
  final String username;
  // Caption text, can be null
  final String? caption;
  // Height of the caption box
  final double height;

  const CaptionGlassBox({
    super.key,
    required this.username,
    this.caption,
    required this.height,
  });

  /// Detects if the given text contains any RTL (right-to-left) characters
  bool _isRtl(String text) {
    // This regex checks for characters in the Hebrew, Arabic, and other RTL blocks.
    return RegExp(r'[\u0591-\u07FF\uFB1D-\uFDFD\uFE70-\uFEFC]').hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the caption is RTL
    final isRtl = caption != null && _isRtl(caption!); 

    final ltrLayout = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            username,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(height: 5),
        if (caption != null && caption!.isNotEmpty)
          // Constrain caption width to leave room for action buttons (CSS: max-width: calc(100% - 70px))
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(right: 50),
              child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 70,
              ),
              child: Text(
                caption!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.start,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );

    final rtlLayout = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
                const SizedBox(height: 5),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            username,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        if (caption != null && caption!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 50),
            child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 70,
            ),
            child: Text(
              caption!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          // Background glass effect mimicking CSS `backdrop-filter: blur(6px)`
          GlassContainer.frostedGlass(
            height: height,
            blur: 6, // matches CSS blur(6px)
            frostedOpacity: 0.07,
            borderWidth: 0,
            // Only round the bottom corners to mirror card style in mockup
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            padding: EdgeInsets.zero,
            child: const SizedBox.shrink(),
          ),
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              // More dramatic gradient with deeper contrast
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.1),   // 10% opacity at 10%
                  Colors.black.withValues(alpha: 0.8),   // 80% opacity at 60%
                  Colors.black.withValues(alpha: 0.95),  // 95% opacity at 100%
                ],
                stops: const [0.0, 0.1, 0.6, 1.0],
                tileMode: TileMode.clamp,
              ),
            ),
          ),
          Padding(
            // CSS padding: 24px 20px 20px (top, horizontal, bottom)
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: isRtl ? rtlLayout : ltrLayout,
            ),
          ),
        ],
      ),
    );
  }
}
