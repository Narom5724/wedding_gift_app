import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:wedding_gift_app/models/wedding/wedding_model.dart';
import 'package:wedding_gift_app/screen/wedding/widget/wedding_card_widget.dart';

class WeddingDataTable extends StatelessWidget {
  const WeddingDataTable({
    super.key,
    required this.weddings,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final List<WeddingModel> weddings;
  final ValueChanged<WeddingModel> onView;
  final ValueChanged<WeddingModel> onEdit;
  final ValueChanged<WeddingModel> onDelete;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showFullDetails = constraints.maxWidth >= 1000;
        final theme = Theme.of(context);
        final columns = showFullDetails
            ? const [3, 3, 2, 2, 2, 1]
            : const [4, 3, 3, 1];

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                color: theme.colorScheme.surfaceContainerLow,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  height: 54,
                  child: Row(
                    children: [
                      _HeaderCell(label: 'wedding'.tr, flex: columns[0]),
                      if (showFullDetails)
                        _HeaderCell(label: 'couple'.tr, flex: columns[1]),
                      _HeaderCell(
                        label: 'location'.tr,
                        flex: showFullDetails ? columns[2] : columns[1],
                      ),
                      _HeaderCell(
                        label: 'wedding_date'.tr,
                        flex: showFullDetails ? columns[3] : columns[2],
                      ),
                      if (showFullDetails)
                        _HeaderCell(label: 'wedding_time'.tr, flex: columns[4]),
                      _HeaderCell(
                        label: 'actions'.tr,
                        flex: columns.last,
                        align: Alignment.center,
                      ),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, color: theme.colorScheme.outlineVariant),
              for (var index = 0; index < weddings.length; index++) ...[
                _WeddingTableRow(
                  wedding: weddings[index],
                  showFullDetails: showFullDetails,
                  columns: columns,
                  onView: () => onView(weddings[index]),
                  onEdit: () => onEdit(weddings[index]),
                  onDelete: () => onDelete(weddings[index]),
                ),
                if (index < weddings.length - 1)
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.label,
    required this.flex,
    this.align = Alignment.centerLeft,
  });

  final String label;
  final int flex;
  final Alignment align;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Align(
          alignment: align,
          child: Text(
            label.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _WeddingTableRow extends StatelessWidget {
  const _WeddingTableRow({
    required this.wedding,
    required this.showFullDetails,
    required this.columns,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final WeddingModel wedding;
  final bool showFullDetails;
  final List<int> columns;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Row(
        children: [
          Expanded(
            flex: columns[0],
            child: InkWell(
              onTap: onView,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    WeddingImageWidget(wedding: wedding, size: 38),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        wedding.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (showFullDetails)
            _ValueCell(
              flex: columns[1],
              value: '${wedding.groomName} & ${wedding.brideName}',
              onTap: onView,
            ),
          _ValueCell(
            flex: showFullDetails ? columns[2] : columns[1],
            value: wedding.weddingLocation,
            onTap: onView,
          ),
          _ValueCell(
            flex: showFullDetails ? columns[3] : columns[2],
            value: DateFormat('dd MMM yyyy').format(wedding.weddingDate),
            onTap: onView,
          ),
          if (showFullDetails)
            _ValueCell(
              flex: columns[4],
              value: wedding.weddingTime.isEmpty
                  ? 'not_provided'.tr
                  : wedding.weddingTime,
              onTap: onView,
            ),
          Expanded(
            flex: columns.last,
            child: WeddingActionsWidget(
              onView: onView,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueCell extends StatelessWidget {
  const _ValueCell({
    required this.flex,
    required this.value,
    required this.onTap,
  });

  final int flex;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            value.isEmpty ? 'not_provided'.tr : value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
