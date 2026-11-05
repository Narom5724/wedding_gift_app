import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wedding_gift_app/controller/setting_controller.dart';

class SettingScreen extends GetView<SettingController> {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr)),
      body: Obx(
        () => ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.language_rounded),
              title: Text('language'.tr),
              trailing: DropdownButton<String>(
                value: controller.language.value,
                underline: const SizedBox.shrink(),
                items: [
                  DropdownMenuItem(value: 'en', child: Text('english'.tr)),
                  DropdownMenuItem(value: 'km', child: Text('khmer'.tr)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _updateSetting(() => controller.changeLanguage(value));
                  }
                },
              ),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.notifications_outlined),
              title: Text('notifications'.tr),
              subtitle: Text('notifications_description'.tr),
              value: controller.notificationsEnabled.value,
              onChanged: (value) => _updateSetting(
                () => controller.setNotificationsEnabled(value),
              ),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: Text('dark_mode'.tr),
              subtitle: Text('dark_mode_description'.tr),
              value: controller.isDark.value,
              onChanged: (value) =>
                  _updateSetting(() => controller.setDarkMode(value)),
            ),
            ListTile(
              leading: const Icon(Icons.currency_exchange_rounded),
              title: Text('default_display_currency'.tr),
              trailing: const Text('USD'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateSetting(Future<void> Function() update) async {
    try {
      await update();
    } catch (error) {
      Get.snackbar(
        'settings_update_failed'.tr,
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
