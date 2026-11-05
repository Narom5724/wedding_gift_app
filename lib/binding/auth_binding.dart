import 'package:get/get.dart';

import 'package:wedding_gift_app/controller/login_controller.dart';
import 'package:wedding_gift_app/controller/register_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterController>(() => RegisterController());
  }
}
