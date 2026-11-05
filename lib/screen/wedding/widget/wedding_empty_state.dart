import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WeddingEmptyState extends StatelessWidget {
  const WeddingEmptyState({
    super.key,
    required this.isFiltered,
    required this.onClearFilters,
    required this.onAddWedding,
  });

  final bool isFiltered;
  final VoidCallback onClearFilters;
  final VoidCallback onAddWedding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                isFiltered
                    ? Icons.search_off_rounded
                    : Icons.favorite_border_rounded,
                size: 36,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              (isFiltered ? 'no_weddings_match_filter' : 'no_weddings_yet').tr,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              (isFiltered ? 'try_adjust_wedding_filters' : 'add_first_wedding')
                  .tr,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            if (isFiltered)
              OutlinedButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.close_rounded),
                label: Text('clear_search'.tr),
              )
            else
              FilledButton.icon(
                onPressed: onAddWedding,
                icon: const Icon(Icons.add_rounded),
                label: Text('add_wedding'.tr),
              ),
          ],
        ),
      ),
    );
  }
}
