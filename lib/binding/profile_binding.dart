import 'package:get/get.dart';

import 'package:wedding_gift_app/controller/auth_controller.dart';
import 'package:wedding_gift_app/controller/setting_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<SettingController>(() => SettingController());
  }
}
