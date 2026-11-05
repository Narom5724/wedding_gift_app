import 'package:get/get.dart';

import 'package:wedding_gift_app/controller/gift_controller.dart';

class GiftBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GiftController>(() => GiftController());
  }
}
