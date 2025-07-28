import 'package:flutter/material.dart';
import 'package:rivo_app_beta/features/product/domain/product.dart';

class KeyInfo extends StatelessWidget {
  const KeyInfo({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: [
          _buildInfoItem('Size', product.size),
          _buildInfoItem('Fabric', product.fabric),
          _buildInfoItem('Condition', product.condition),
          _buildInfoItem('Brand', product.brand),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
