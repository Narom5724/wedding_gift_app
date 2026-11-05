import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:wedding_gift_app/controller/report_controller.dart';
import 'package:wedding_gift_app/models/report/gift_report_model.dart';
import 'package:wedding_gift_app/screen/widgets/app_record_table.dart';

class ReportScreen extends GetView<ReportController> {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;

        return Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: Get.back),
            title: Text('reports'.tr),
          ),
          body: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.all(isWide ? 12 : 16),
              child: Obx(() {
                final reports = controller.filteredReports;

                return Column(
                  children: [
                    TextField(
                      onChanged: controller.updateSearch,
                      decoration: InputDecoration(
                        hintText: 'search_reports'.tr,
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: IconButton(
                          tooltip: 'refresh_reports'.tr,
                          onPressed: controller.loadReports,
                          icon: const Icon(Icons.refresh_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${reports.length} ${'reports'.tr.toUpperCase()}',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _buildReportContent(
                        context: context,
                        reports: reports,
                        isWide: isWide,
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

  Widget _buildReportContent({
    required BuildContext context,
    required List<GiftReportModel> reports,
    required bool isWide,
  }) {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.errorMessage.value.isNotEmpty) {
      return Center(child: Text(controller.errorMessage.value));
    }
    if (reports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            (controller.reportList.isEmpty
                    ? 'no_weddings_for_report'
                    : 'no_reports_match_search')
                .tr,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (isWide) {
      return RefreshIndicator(
        onRefresh: controller.loadReports,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: AppRecordTable(
            columns: const [
              'Wedding',
              'Gift records',
              'USD total',
              'KHR total',
            ],
            rows: reports.map((item) {
              return [
                Text(item.weddingName),
                Text('${item.giftCount}'),
                Text('\$${NumberFormat('#,##0.00').format(item.totalUsd)}'),
                Text('៛${NumberFormat('#,##0').format(item.totalKhr)}'),
              ];
            }).toList(),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.loadReports,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: reports.map((item) {
          final theme = Theme.of(context);
          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            elevation: 1,
            shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              title: Text(item.weddingName),
              subtitle: Text('Gift records: ${item.giftCount}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('\$${NumberFormat('#,##0.00').format(item.totalUsd)}'),
                  Text('៛${NumberFormat('#,##0').format(item.totalKhr)}'),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
