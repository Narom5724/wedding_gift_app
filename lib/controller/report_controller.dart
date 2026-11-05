import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:wedding_gift_app/models/report/gift_report_model.dart';
import 'package:wedding_gift_app/services/report_service.dart';

class ReportController extends GetxController {
  final ReportService _service = ReportService();
  final reportList = <GiftReportModel>[].obs;
  final searchText = ''.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  List<GiftReportModel> get filteredReports {
    final query = searchText.value.trim().toLowerCase();
    if (query.isEmpty) return reportList.toList();
    return reportList
        .where((report) => report.weddingName.toLowerCase().contains(query))
        .toList();
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
      reportList.assignAll(await _service.fetchReports());
    } catch (error, stackTrace) {
      errorMessage.value = 'Unable to load reports: $error';
      debugPrint('Unable to load reports: $error\n$stackTrace');
    } finally {
      isLoading.value = false;
    }
  }
}
