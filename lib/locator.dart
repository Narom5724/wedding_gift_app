import 'package:get/get.dart';

import 'services/storage_service.dart';

void setupLocator() {
  Get.lazyPut(() => StorageService(), fenix: true);
}
