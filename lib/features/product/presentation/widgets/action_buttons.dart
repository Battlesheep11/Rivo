import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({
    super.key,
    required this.onSavePressed,
    required this.onSharePressed,
    required this.onBuyNowPressed,
  });

  final VoidCallback onSavePressed;
  final VoidCallback onSharePressed;
  final VoidCallback onBuyNowPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        children: [
          _buildActionButton(icon: Icons.favorite_border, onPressed: onSavePressed, color: Colors.redAccent),
          const SizedBox(width: 12),
          _buildActionButton(icon: Icons.share, onPressed: onSharePressed),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: onBuyNowPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Buy Now'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        icon: Icon(icon, color: color ?? Colors.black87),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: Colors.grey[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[300]!),
          ),
        ),
      ),
    );
  }
}
