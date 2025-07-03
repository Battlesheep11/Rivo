import 'package:flutter/material.dart';

class GlassText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;

  const GlassText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
      textAlign: textAlign,
      style: (style ?? Theme.of(context).textTheme.headlineSmall)?.copyWith(
        color: Colors.white,
        shadows: [
          const Shadow(
            offset: Offset(0, 1.5),
            blurRadius: 4,
            color: Colors.black26,
          ),
        ],
      ),
    );
  }
}
