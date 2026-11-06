import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:wedding_gift_app/models/gift/gift_model.dart';
import 'package:wedding_gift_app/utils/currency_helper.dart';

class GiftDetailWidget extends StatelessWidget {
  const GiftDetailWidget({super.key, required this.gift, required this.guestName, required this.weddingName});

  final GiftModel gift;
  final String guestName;
  final String weddingName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 700),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 16, 14),
            child: Row(children: [
              Expanded(child: Text('gift_details'.tr, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
              IconButton(tooltip: 'close'.tr, onPressed: Get.back, icon: const Icon(Icons.close_rounded)),
            ]),
          ),
          Divider(height: 1, color: colors.outlineVariant),
          Flexible(child: ListView(padding: const EdgeInsets.all(24), children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [colors.primary, colors.primary.withValues(alpha: .82)]),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(children: [
                Container(width: 52, height: 52, decoration: BoxDecoration(color: colors.onPrimary.withValues(alpha: .16), borderRadius: BorderRadius.circular(17)), child: Icon(Icons.card_giftcard_rounded, color: colors.onPrimary, size: 27)),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('amount'.tr.toUpperCase(), style: theme.textTheme.labelSmall?.copyWith(color: colors.onPrimary.withValues(alpha: .8), letterSpacing: 1.1, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(CurrencyHelper.formatAmount(gift.amount, gift.currency), style: theme.textTheme.headlineSmall?.copyWith(color: colors.onPrimary, fontWeight: FontWeight.w700)),
                ])),
              ]),
            ),
            const SizedBox(height: 24),
            Text('linked_records'.tr.toUpperCase(), style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.1, fontWeight: FontWeight.w700, color: colors.onSurfaceVariant)),
            const SizedBox(height: 8),
            _DetailRow(icon: Icons.favorite_border_rounded, label: 'wedding'.tr, value: weddingName),
            _DetailRow(icon: Icons.person_outline_rounded, label: 'guest'.tr, value: guestName),
            const SizedBox(height: 8),
            Text('gift_details'.tr.toUpperCase(), style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.1, fontWeight: FontWeight.w700, color: colors.onSurfaceVariant)),
            const SizedBox(height: 8),
            _DetailRow(icon: Icons.payments_outlined, label: 'received_by'.tr, value: gift.paymentMethod),
            _DetailRow(icon: Icons.calendar_month_outlined, label: 'gift_date'.tr, value: DateFormat('EEEE, dd MMMM yyyy').format(gift.receivedDate)),
            if (gift.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('notes'.tr.toUpperCase(), style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.1, fontWeight: FontWeight.w700, color: colors.onSurfaceVariant)),
              const SizedBox(height: 10),
              Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: colors.surfaceContainerLow, borderRadius: BorderRadius.circular(18), border: Border.all(color: colors.outlineVariant.withValues(alpha: .65))), child: Text(gift.notes, style: theme.textTheme.bodyMedium?.copyWith(height: 1.45))),
            ],
          ])),
        ]),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: colors.primaryContainer.withValues(alpha: .6), borderRadius: BorderRadius.circular(13)), child: Icon(icon, size: 20, color: colors.primary)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: colors.onSurfaceVariant)),
          const SizedBox(height: 3),
          Text(value.isEmpty ? 'not_provided'.tr : value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
        ])),
      ]),
    );
  }
}
