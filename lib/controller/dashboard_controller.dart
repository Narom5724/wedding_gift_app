import 'package:get/get.dart';

import 'package:wedding_gift_app/models/dashboard/dashboard_summary_model.dart';
import 'package:wedding_gift_app/services/dashboard_service.dart';

class DashboardController extends GetxController {
  final DashboardService _service = DashboardService();
  final summary = DashboardSummaryModel(
    totalWeddings: 0,
    totalGuests: 0,
    totalGiftRecords: 0,
    totalUsd: 0,
    totalKhr: 0,
  ).obs;

  final upcomingWeddings = <String>[].obs;
  final weddingNames = <String, String>{}.obs;
  final guestNames = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    final data = await _service.fetchSummary();
    summary.value = DashboardSummaryModel(
      totalWeddings: (data['totalWeddings'] as num?)?.toInt() ?? 0,
      totalGuests: (data['totalGuests'] as num?)?.toInt() ?? 0,
      totalGiftRecords: (data['totalGiftRecords'] as num?)?.toInt() ?? 0,
      totalUsd: (data['totalUsd'] as num?)?.toDouble() ?? 0,
      totalKhr: (data['totalKhr'] as num?)?.toDouble() ?? 0,
    );
    upcomingWeddings.assignAll(
      (data['upcomingWeddings'] as List<dynamic>? ?? const []).map(
        (item) => item.toString(),
      ),
    );
    weddingNames.assignAll(
      data['weddingNames'] as Map<String, String>? ?? const {},
    );
    guestNames.assignAll(
      data['guestNames'] as Map<String, String>? ?? const {},
    );
  }
}
