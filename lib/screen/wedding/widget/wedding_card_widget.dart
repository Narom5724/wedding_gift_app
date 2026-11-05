import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:wedding_gift_app/models/wedding/wedding_model.dart';

class WeddingCardWidget extends StatelessWidget {
  const WeddingCardWidget({
    super.key,
    required this.wedding,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final WeddingModel wedding;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WeddingImage(wedding: wedding, size: 64),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wedding.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${wedding.groomName} & ${wedding.brideName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  _WeddingInfoRow(
                    icon: Icons.location_on_outlined,
                    text: wedding.weddingLocation,
                  ),
                  const SizedBox(height: 6),
                  _WeddingInfoRow(
                    icon: Icons.calendar_month_outlined,
                    text: DateFormat('dd MMM yyyy').format(wedding.weddingDate),
                  ),
                  if (wedding.weddingTime.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _WeddingInfoRow(
                      icon: Icons.access_time_rounded,
                      text: wedding.weddingTime,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 4),
            _WeddingActions(onView: onView, onEdit: onEdit, onDelete: onDelete),
          ],
        ),
      ),
    );
  }
}

class WeddingImageWidget extends StatelessWidget {
  const WeddingImageWidget({super.key, required this.wedding, this.size = 40});

  final WeddingModel wedding;
  final double size;

  @override
  Widget build(BuildContext context) =>
      _WeddingImage(wedding: wedding, size: size);
}

class _WeddingImage extends StatelessWidget {
  const _WeddingImage({required this.wedding, required this.size});

  final WeddingModel wedding;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child: SizedBox(
        width: size,
        height: size,
        child: wedding.coverImageUrl.isEmpty
            ? ColoredBox(
                color: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.favorite_rounded,
                  color: theme.colorScheme.primary,
                  size: size * 0.48,
                ),
              )
            : Image.network(
                wedding.coverImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => ColoredBox(
                  color: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.favorite_rounded,
                    color: theme.colorScheme.primary,
                    size: size * 0.48,
                  ),
                ),
              ),
      ),
    );
  }
}

class _WeddingInfoRow extends StatelessWidget {
  const _WeddingInfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text.isEmpty ? 'not_provided'.tr : text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class WeddingActionsWidget extends StatelessWidget {
  const WeddingActionsWidget({
    super.key,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) =>
      _WeddingActions(onView: onView, onEdit: onEdit, onDelete: onDelete);
}

class _WeddingActions extends StatelessWidget {
  const _WeddingActions({
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'wedding_actions'.tr,
      icon: const Icon(Icons.more_vert_rounded),
      onSelected: (action) {
        switch (action) {
          case 'view':
            onView();
          case 'edit':
            onEdit();
          case 'delete':
            onDelete();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'view',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.visibility_outlined),
            title: Text('view_details'.tr),
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.edit_outlined),
            title: Text('edit'.tr),
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.delete_outline_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text('delete'.tr),
          ),
        ),
      ],
    );
  }
}
