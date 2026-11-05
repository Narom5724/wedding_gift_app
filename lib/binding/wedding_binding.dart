import 'package:get/get.dart';

import 'package:wedding_gift_app/controller/wedding_controller.dart';
import 'package:wedding_gift_app/services/wedding_service.dart';

class WeddingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WeddingService>(() => WeddingService());
    Get.lazyPut<WeddingController>(
      () => WeddingController(Get.find<WeddingService>()),
    );
  }
}
