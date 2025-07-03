import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppSvgIcon extends StatelessWidget {
  final String url;
  final double size;
  final Color? color;

  const AppSvgIcon({
    super.key,
    required this.url,
    this.size = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.network(
      url,
      width: size,
      height: size,
      placeholderBuilder: (_) => SizedBox(width: size, height: size),
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}
