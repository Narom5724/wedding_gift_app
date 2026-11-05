import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingController extends GetxController {
  final _storage = GetStorage();
  final language = 'en'.obs;
  final isDark = false.obs;
  final notificationsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    language.value = _storage.read<String>('language') ?? 'en';
    isDark.value = _storage.read<bool>('isDarkMode') ?? false;
    notificationsEnabled.value =
        _storage.read<bool>('notificationsEnabled') ?? true;
  }

  Future<void> changeLanguage(String code) async {
    if (code != 'en' && code != 'km') {
      throw ArgumentError.value(code, 'code', 'Unsupported language.');
    }
    await _storage.write('language', code);
    language.value = code;
    Get.updateLocale(Locale(code));
  }

  Future<void> setDarkMode(bool enabled) async {
    await _storage.write('isDarkMode', enabled);
    isDark.value = enabled;
    Get.changeThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _storage.write('notificationsEnabled', enabled);
    notificationsEnabled.value = enabled;
  }
}
