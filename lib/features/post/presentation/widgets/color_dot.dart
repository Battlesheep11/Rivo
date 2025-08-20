import 'package:flutter/material.dart';

class ColorDot extends StatelessWidget {
  final String hex;
  final bool isSelected;

  const ColorDot({
    super.key,
    required this.hex,
    required this.isSelected,
  });

  Color parseColor(String hex) {
    final cleanedHex = hex.replaceFirst('#', '');
    final fullHex = cleanedHex.length == 6 ? 'FF$cleanedHex' : cleanedHex;
    return Color(int.parse(fullHex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final color = parseColor(hex);

    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: isSelected
            ? Border.all(color: Colors.black, width: 3)
            : Border.all(color: Colors.grey.shade400),
      ),
    );
  }
}
