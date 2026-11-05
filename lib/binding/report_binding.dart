import 'package:get/get.dart';

import 'package:wedding_gift_app/controller/report_controller.dart';

class ReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportController>(() => ReportController());
  }
}
