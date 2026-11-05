import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:wedding_gift_app/screen/manage/manage_screen.dart';
import 'package:wedding_gift_app/utils/app_translations.dart';

void main() {
  testWidgets('manage screen shows app sections and supports search', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        fallbackLocale: const Locale('en'),
        home: const ManageScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Wedding Management'), findsOneWidget);
    expect(find.text('Guests'), findsOneWidget);
    expect(find.text('Gifts'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'guest');
    await tester.pumpAndSettle();

    expect(find.text('Guests'), findsOneWidget);
    expect(find.text('Gifts'), findsNothing);
    expect(find.text('Gallery'), findsNothing);
    expect(find.text('Reports'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
