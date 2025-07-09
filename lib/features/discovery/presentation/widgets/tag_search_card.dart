import 'package:flutter/material.dart';
import 'package:rivo_app/features/discovery/domain/entities/tag_search_entity.dart';

class TagSearchCard extends StatelessWidget {
  final TagSearchEntity tag;
  final VoidCallback? onTap;

  const TagSearchCard({
    super.key,
    required this.tag,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.tag, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '#${tag.name}',
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
