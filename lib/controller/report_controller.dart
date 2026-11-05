import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:wedding_gift_app/models/report/gift_report_model.dart';
import 'package:wedding_gift_app/services/report_export_service.dart';
import 'package:wedding_gift_app/services/report_service.dart';

class ReportController extends GetxController {
  final ReportService _service = ReportService();
  final ReportExportService _exportService = ReportExportService();
  final reportData = const GiftReportData().obs;
  final searchText = ''.obs;
  final isLoading = false.obs;
  final isExporting = false.obs;
  final errorMessage = ''.obs;

  List<WeddingGiftReport> get filteredWeddings {
    final query = searchText.value.trim().toLowerCase();
    if (query.isEmpty) return reportData.value.weddings;
    return reportData.value.weddings
        .where((report) => report.weddingName.toLowerCase().contains(query))
        .toList();
  }

  List<GuestGiftReport> get filteredGuests {
    final query = searchText.value.trim().toLowerCase();
    if (query.isEmpty) return reportData.value.guests;
    return reportData.value.guests.where((report) {
      return report.guestName.toLowerCase().contains(query) ||
          report.relationship.toLowerCase().contains(query) ||
          report.phone.toLowerCase().contains(query) ||
          report.weddingName.toLowerCase().contains(query);
    }).toList();
  }

  void updateSearch(String value) => searchText.value = value;

  @override
  void onInit() {
    super.onInit();
    loadReports();
  }

  Future<void> loadReports() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      reportData.value = await _service.fetchReports();
    } catch (error, stackTrace) {
      errorMessage.value = 'Unable to load reports: $error';
      debugPrint('Unable to load reports: $error\n$stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> exportExcel() => _export(_exportService.exportExcel);

  Future<void> exportPdf() => _export(_exportService.exportPdf);

  Future<void> _export(Future<bool> Function(GiftReportData) export) async {
    if (isExporting.value || isLoading.value) return;
    isExporting.value = true;
    try {
      final saved = await export(reportData.value);
      if (!saved) return;
      Get.snackbar(
        'report_exported'.tr,
        'report_export_success'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error, stackTrace) {
      debugPrint('Unable to export report: $error\n$stackTrace');
      Get.snackbar(
        'report_export_failed'.tr,
        'report_export_failed_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isExporting.value = false;
    }
  }
}
