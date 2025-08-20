import 'package:flutter/material.dart';
import 'package:rivo_app_beta/features/product/domain/product.dart';
import 'package:rivo_app_beta/features/product/domain/utils/item_condition_label.dart';

class KeyInfo extends StatelessWidget {
  const KeyInfo({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final sizeText = (product.size.trim().isNotEmpty) ? product.size : '—';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Table(
        columnWidths: const {0: FlexColumnWidth(), 1: FlexColumnWidth()},
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            _Spec(label: 'Fabric', value: product.fabric.isNotEmpty ? product.fabric : 'N/A'),
            _Spec(label: 'Size', value: sizeText),
          ]),
          const TableRow(children: [SizedBox(height: 12), SizedBox(height: 12)]),
          TableRow(children: [
            _Spec(
              label: 'Condition',
              value: product.condition.isNotEmpty
                  ? itemConditionLabel(context, product.condition)
                  : '—',
            ),
            _Spec(label: 'Brand', value: product.brand.trim().isNotEmpty ? product.brand : '—'),
          ]),
        ],
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  const _Spec({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 3,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
