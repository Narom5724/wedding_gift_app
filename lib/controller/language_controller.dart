import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageController extends GetxController {
  final currentLanguage = 'en'.obs;

  void changeLanguage(String code) {
    currentLanguage.value = code;
    Get.updateLocale(Locale(code));
  }
}
