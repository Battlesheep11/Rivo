import 'package:flutter/material.dart';
import 'package:rivo_app/features/discovery/domain/entities/discovery_tag_entity.dart';
import 'package:rivo_app/core/design_system/tags/app_tag_chip.dart';

class TrendingTagChip extends StatelessWidget {
  final DiscoveryTagEntity tag;
  final VoidCallback? onTap;

  const TrendingTagChip({super.key, required this.tag, this.onTap});

  @override
  Widget build(BuildContext context) {
    final label = '#${tag.name}';
    final isRTL = _isRTL(tag.name);

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: AppTagChip(
        label: label,
        onTap: onTap,
      ),
    );
  }

  bool _isRTL(String text) {
    if (text.isEmpty) return false;
    final firstChar = text.codeUnitAt(0);
    return (firstChar >= 0x0590 && firstChar <= 0x08FF);
  }
}
