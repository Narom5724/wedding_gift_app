import 'package:get/get.dart';

import 'package:wedding_gift_app/controller/guest_controller.dart';

class GuestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GuestController>(() => GuestController());
  }
}
