import 'package:flutter/material.dart';

class CaptionGlassBox extends StatelessWidget {
  final String title;
  final String seller;
  final String price;
  final double height;

  const CaptionGlassBox({
    super.key,
    required this.title,
    required this.seller,
    required this.price,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x00000000),  // transparent
            Color(0xB8000000),  // 72% black
          ],
          stops: [0.0, 0.8],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
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
          
          const SizedBox(height: 4),
          
          // Seller
          Text(
            'By $seller',
            style: const TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              height: 1.3,
              color: Color(0xE6FFFFFF),
              letterSpacing: -0.3,
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
    );
  }
}
