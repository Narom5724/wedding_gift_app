import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/guest/guest_model.dart';

class GuestDetailWidget extends StatelessWidget {
  const GuestDetailWidget({super.key, required this.guest});

  final GuestModel guest;

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
              Expanded(child: Text('guest_information'.tr, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
              IconButton(tooltip: 'close'.tr, onPressed: Get.back, icon: const Icon(Icons.close_rounded)),
            ]),
          ),
          Divider(height: 1, color: colors.outlineVariant),
          Flexible(child: ListView(padding: const EdgeInsets.all(24), children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: colors.primaryContainer.withValues(alpha: .55), borderRadius: BorderRadius.circular(22)),
              child: Row(children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: colors.surface,
                  child: Text(_initials(guest.fullName), style: theme.textTheme.titleMedium?.copyWith(color: colors.primary, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(guest.fullName, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: colors.surface.withValues(alpha: .8), borderRadius: BorderRadius.circular(30)),
                    child: Text(guest.relationship.isEmpty ? 'not_provided'.tr : guest.relationship, style: theme.textTheme.labelMedium?.copyWith(color: colors.primary, fontWeight: FontWeight.w600)),
                  ),
                ])),
              ]),
            ),
            const SizedBox(height: 24),
            _SectionLabel(title: 'personal_information'.tr),
            const SizedBox(height: 8),
            _DetailRow(icon: Icons.phone_outlined, label: 'phone_number'.tr, value: guest.phone),
            _DetailRow(icon: Icons.location_on_outlined, label: 'address'.tr, value: guest.address),
            if (guest.gender.isNotEmpty) _DetailRow(icon: Icons.wc_rounded, label: 'gender'.tr, value: guest.gender),
            if (guest.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              _SectionLabel(title: 'notes'.tr),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: colors.surfaceContainerLow, borderRadius: BorderRadius.circular(18), border: Border.all(color: colors.outlineVariant.withValues(alpha: .65))),
                child: Text(guest.notes, style: theme.textTheme.bodyMedium?.copyWith(height: 1.45)),
              ),
            ],
          ])),
        ]),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).take(2);
    final result = parts
        .map((part) => part.substring(0, 1).toUpperCase())
        .join();
    return result.isEmpty ? '?' : result;
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Text(title.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.1, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurfaceVariant));
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
