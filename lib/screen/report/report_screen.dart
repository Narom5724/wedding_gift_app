import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:wedding_gift_app/controller/report_controller.dart';

class ReportScreen extends GetView<ReportController> {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: RefreshIndicator(
        onRefresh: controller.loadReports,
        child: LayoutBuilder(
          builder: (context, constraints) => Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.errorMessage.value.isNotEmpty) {
              return Center(child: Text(controller.errorMessage.value));
            }
            if (controller.reportList.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No weddings yet. Create a wedding to see its report here.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (constraints.maxWidth >= 760) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Wedding')),
                        DataColumn(label: Text('Gift records')),
                        DataColumn(label: Text('USD total')),
                        DataColumn(label: Text('KHR total')),
                      ],
                      rows: controller.reportList.map((item) {
                        return DataRow(
                          cells: [
                            DataCell(Text(item.weddingName)),
                            DataCell(Text('${item.giftCount}')),
                            DataCell(
                              Text(
                                '\$${NumberFormat('#,##0.00').format(item.totalUsd)}',
                              ),
                            ),
                            DataCell(
                              Text(
                                '៛${NumberFormat('#,##0').format(item.totalKhr)}',
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: controller.reportList.map((item) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(item.weddingName),
                    subtitle: Text('Gift records: ${item.giftCount}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${NumberFormat('#,##0.00').format(item.totalUsd)}',
                        ),
                        Text('៛${NumberFormat('#,##0').format(item.totalKhr)}'),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ),
      ),
    );
  }
}
