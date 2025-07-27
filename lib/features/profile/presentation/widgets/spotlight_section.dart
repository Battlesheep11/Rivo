import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:rivo_app_beta/core/design_system/design_system.dart';

class SpotlightSection extends StatelessWidget {
  const SpotlightSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Spotlight', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                // Placeholder for actual spotlight items
                _AddSpotlightButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddSpotlightButton extends StatefulWidget {
  const _AddSpotlightButton();

  @override
  _AddSpotlightButtonState createState() => _AddSpotlightButtonState();
}

class _AddSpotlightButtonState extends State<_AddSpotlightButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = _isPressed ? AppColors.onSurface : AppColors.gray400;

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          color: color,
          strokeWidth: _isPressed ? 2.5 : 1.5,
          dashPattern: const [6, 4],
          radius: const Radius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: Container(
            width: 100,
            height: 120,
            color: AppColors.primary.withAlpha(13),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: color, size: 24),
                const SizedBox(height: 8),
                Text(
                  'Add to Spotlight',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontWeight: _isPressed ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
