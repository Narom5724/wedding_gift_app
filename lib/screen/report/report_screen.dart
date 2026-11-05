import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:wedding_gift_app/controller/report_controller.dart';
import 'package:wedding_gift_app/models/report/gift_report_model.dart';

class ReportScreen extends GetView<ReportController> {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 760;
        return Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: Get.back),
            title: Text('reports'.tr),
            actions: [
              IconButton(
                tooltip: 'refresh_reports'.tr,
                onPressed: controller.loadReports,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.all(isWide ? 16 : 12),
              child: Obx(() {
                final data = controller.reportData.value;
                final hasData = data.weddings.isNotEmpty ||
                    data.guests.isNotEmpty ||
                    data.giftCount > 0;
                if (controller.isLoading.value && !hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.errorMessage.value.isNotEmpty && !hasData) {
                  return _ErrorState(
                    message: controller.errorMessage.value,
                    onRetry: controller.loadReports,
                  );
                }

                return Column(
                  children: [
                    TextField(
                      onChanged: controller.updateSearch,
                      decoration: InputDecoration(
                        hintText: 'report_search_hint'.tr,
                        prefixIcon: const Icon(Icons.search_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: controller.isExporting.value ||
                                    controller.isLoading.value
                                ? null
                                : controller.exportExcel,
                            icon: const Icon(Icons.table_view_rounded),
                            label: Text('report_export_excel'.tr),
                          ),
                          FilledButton.icon(
                            onPressed: controller.isExporting.value ||
                                    controller.isLoading.value
                                ? null
                                : controller.exportPdf,
                            icon: controller.isExporting.value
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.picture_as_pdf_rounded),
                            label: Text('report_export_pdf'.tr),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: controller.loadReports,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            _summaryCards(data),
                            const SizedBox(height: 12),
                            _weddingSection(
                              controller.filteredWeddings,
                            ),
                            const SizedBox(height: 12),
                            if (isWide)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _periodSection(
                                      title: 'report_by_day'.tr,
                                      reports: data.byDay,
                                      pattern: 'dd MMM yyyy',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _periodSection(
                                      title: 'report_by_month'.tr,
                                      reports: data.byMonth,
                                      pattern: 'MMM yyyy',
                                    ),
                                  ),
                                ],
                              )
                            else ...[
                              _periodSection(
                                title: 'report_by_day'.tr,
                                reports: data.byDay,
                                pattern: 'dd MMM yyyy',
                              ),
                              const SizedBox(height: 12),
                              _periodSection(
                                title: 'report_by_month'.tr,
                                reports: data.byMonth,
                                pattern: 'MMM yyyy',
                              ),
                            ],
                            const SizedBox(height: 12),
                            _guestSection(controller.filteredGuests),
                            const SizedBox(height: 12),
                            _largestGiftSection(context, data),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _summaryCards(GiftReportData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900 ? 4 : 2;
        final cardWidth =
            (constraints.maxWidth - (12 * (columns - 1))) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricCard(
              width: cardWidth,
              label: 'total_guests'.tr,
              value: '${data.guestCount}',
              icon: Icons.people_alt_outlined,
            ),
            _MetricCard(
              width: cardWidth,
              label: 'total_gift_records'.tr,
              value: '${data.giftCount}',
              icon: Icons.receipt_long_rounded,
            ),
            _MetricCard(
              width: cardWidth,
              label: 'total_amount_usd'.tr,
              value: _money(data.totalUsd, 'USD'),
              icon: Icons.attach_money_rounded,
            ),
            _MetricCard(
              width: cardWidth,
              label: 'total_amount_khr'.tr,
              value: _money(data.totalKhr, 'KHR'),
              icon: Icons.payments_outlined,
            ),
          ],
        );
      },
    );
  }

  Widget _weddingSection(List<WeddingGiftReport> reports) {
    return _SectionCard(
      title: 'report_by_wedding'.tr,
      icon: Icons.favorite_border_rounded,
      child: reports.isEmpty
          ? _emptySection()
          : Column(
              children: [
                for (final report in reports)
                  _ReportRow(
                    title: report.weddingName,
                    subtitle: '${report.giftCount} ${'report_gift_count'.tr}',
                    usd: report.totalUsd,
                    khr: report.totalKhr,
                    isLast: identical(reports.last, report),
                  ),
              ],
            ),
    );
  }

  Widget _periodSection({
    required String title,
    required List<GiftPeriodReport> reports,
    required String pattern,
  }) {
    return _SectionCard(
      title: title,
      icon: Icons.calendar_month_rounded,
      child: reports.isEmpty
          ? _emptySection()
          : Column(
              children: [
                for (var i = 0; i < reports.length; i++)
                  _ReportRow(
                    title: DateFormat(pattern).format(reports[i].period),
                    subtitle:
                        '${reports[i].giftCount} ${'report_gift_count'.tr}',
                    usd: reports[i].totalUsd,
                    khr: reports[i].totalKhr,
                    isLast: i == reports.length - 1,
                  ),
              ],
            ),
    );
  }

  Widget _guestSection(List<GuestGiftReport> reports) {
    return _SectionCard(
      title: 'report_guest_list'.tr,
      icon: Icons.groups_2_outlined,
      child: reports.isEmpty
          ? _emptySection()
          : Column(
              children: [
                for (var i = 0; i < reports.length; i++)
                  _ReportRow(
                    title: reports[i].guestName,
                    subtitle: [
                      reports[i].relationship,
                      reports[i].phone,
                      reports[i].weddingName,
                    ].where((item) => item.isNotEmpty).join(' · '),
                    usd: reports[i].totalUsd,
                    khr: reports[i].totalKhr,
                    isLast: i == reports.length - 1,
                  ),
              ],
            ),
    );
  }

  Widget _largestGiftSection(BuildContext context, GiftReportData data) {
    final largest = [data.largestUsdGift, data.largestKhrGift]
        .whereType<LargestGiftReport>()
        .toList();
    return _SectionCard(
      title: 'report_largest_gifts'.tr,
      icon: Icons.emoji_events_outlined,
      child: largest.isEmpty
          ? _emptySection()
          : Wrap(
              spacing: 12,
              runSpacing: 12,
              children: largest.map((gift) {
                return Container(
                  width: 280,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _money(gift.amount, gift.currency),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(gift.guestName),
                      Text(gift.weddingName),
                      Text(DateFormat('dd MMM yyyy').format(gift.date)),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _emptySection() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text('report_empty_section'.tr),
    ),
  );

  String _money(double amount, String currency) {
    final pattern = currency == 'KHR' ? '#,##0' : '#,##0.00';
    return '$currency ${NumberFormat(pattern).format(amount)}';
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.width,
    required this.label,
    required this.value,
    required this.icon,
  });

  final double width;
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.textTheme.labelMedium),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({
    required this.title,
    required this.subtitle,
    required this.usd,
    required this.khr,
    required this.isLast,
  });

  final String title;
  final String subtitle;
  final double usd;
  final double khr;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('USD ${NumberFormat('#,##0.00').format(usd)}'),
                  Text('KHR ${NumberFormat('#,##0').format(khr)}'),
                ],
              ),
            ],
          ),
          if (!isLast) ...[
            const SizedBox(height: 10),
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
          ],
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('try_again'.tr),
          ),
        ],
      ),
    );
  }
}
