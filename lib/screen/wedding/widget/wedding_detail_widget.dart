import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:wedding_gift_app/models/wedding/wedding_model.dart';

class WeddingDetailWidget extends StatelessWidget {
  const WeddingDetailWidget({super.key, required this.wedding});

  final WeddingModel wedding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'wedding_details'.tr,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'close'.tr,
                    onPressed: Get.back,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: theme.dividerColor),
            Flexible(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (wedding.coverImageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        wedding.coverImageUrl,
                        height: 190,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _imagePlaceholder(context),
                      ),
                    )
                  else
                    _imagePlaceholder(context),
                  const SizedBox(height: 18),
                  Text(wedding.title, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 6),
                  Text(
                    '${wedding.groomName} & ${wedding.brideName}',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  _DetailRow(
                    icon: Icons.calendar_month_outlined,
                    label: 'wedding_date'.tr,
                    value: DateFormat(
                      'EEEE, dd MMMM yyyy',
                    ).format(wedding.weddingDate),
                  ),
                  _DetailRow(
                    icon: Icons.access_time_rounded,
                    label: 'wedding_time'.tr,
                    value: wedding.weddingTime,
                  ),
                  _DetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'location'.tr,
                    value: wedding.weddingLocation,
                  ),
                  _DetailRow(
                    icon: Icons.phone_outlined,
                    label: 'contact_phone'.tr,
                    value: wedding.contactPhone,
                  ),
                  if (wedding.description.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text('notes'.tr, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 6),
                    Text(
                      wedding.description,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        Icons.favorite_rounded,
        size: 56,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelMedium),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? 'not_provided'.tr : value,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
