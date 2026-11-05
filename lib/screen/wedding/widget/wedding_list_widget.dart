import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wedding_gift_app/models/wedding/wedding_model.dart';
import 'package:wedding_gift_app/screen/wedding/widget/wedding_card_widget.dart';
import 'package:wedding_gift_app/screen/wedding/widget/wedding_data_table.dart';
import 'package:wedding_gift_app/screen/wedding/widget/wedding_empty_state.dart';

class WeddingListWidget extends StatelessWidget {
  const WeddingListWidget({
    super.key,
    required this.weddings,
    required this.isLoading,
    this.isDesktopLayout,
    this.errorMessage = '',
    this.isFiltered = false,
    required this.onRefresh,
    required this.onClearFilters,
    required this.onAddWedding,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final List<WeddingModel> weddings;
  final bool isLoading;
  final bool? isDesktopLayout;
  final String errorMessage;
  final bool isFiltered;
  final Future<void> Function() onRefresh;
  final VoidCallback onClearFilters;
  final VoidCallback onAddWedding;
  final ValueChanged<WeddingModel> onView;
  final ValueChanged<WeddingModel> onEdit;
  final Future<void> Function(String) onDelete;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 44,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                label: Text('try_again'.tr),
              ),
            ],
          ),
        ),
      );
    }

    if (weddings.isEmpty) {
      return WeddingEmptyState(
        isFiltered: isFiltered,
        onClearFilters: onClearFilters,
        onAddWedding: onAddWedding,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (isDesktopLayout ?? constraints.maxWidth >= 600) {
          return RefreshIndicator(
            onRefresh: onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: WeddingDataTable(
                weddings: weddings,
                onView: onView,
                onEdit: onEdit,
                onDelete: (wedding) => onDelete(wedding.id),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 12),
            itemCount: weddings.length,
            itemBuilder: (context, index) {
              final wedding = weddings[index];
              return WeddingCardWidget(
                wedding: wedding,
                onView: () => onView(wedding),
                onEdit: () => onEdit(wedding),
                onDelete: () => onDelete(wedding.id),
              );
            },
          ),
        );
      },
    );
  }
}
