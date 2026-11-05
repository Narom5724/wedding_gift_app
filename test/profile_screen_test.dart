import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:wedding_gift_app/controller/auth_controller.dart';
import 'package:wedding_gift_app/controller/setting_controller.dart';
import 'package:wedding_gift_app/screen/profile/profile_screen.dart';
import 'package:wedding_gift_app/utils/app_translations.dart';

void main() {
  testWidgets('profile shows account details and app preferences', (
    tester,
  ) async {
    Get.put(AuthController())
      ..userName.value = 'Sample Planner'
      ..userEmail.value = 'planner@example.com'
      ..userPhoneNumber.value = '+855 12 345 678';
    Get.put<SettingController>(_TestSettingController());
    addTearDown(Get.reset);

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        fallbackLocale: const Locale('en'),
        home: const ProfileScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Sample Planner'), findsWidgets);
    expect(find.text('planner@example.com'), findsWidgets);
    expect(find.text('+855 12 345 678'), findsOneWidget);
    expect(find.text('Personal information'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Dark mode'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Sign out'), 250);
    await tester.pump();
    expect(find.text('Sign out'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _TestSettingController extends SettingController {
  @override
  // ignore: must_call_super
  void onInit() {}
}
