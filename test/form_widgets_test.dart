import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:wedding_gift_app/screen/gift/widget/gift_add_widget.dart';
import 'package:wedding_gift_app/screen/guest/widget/guest_add_widget.dart';
import 'package:wedding_gift_app/screen/wedding/widget/wedding_add_widget.dart';
import 'package:wedding_gift_app/screen/wedding/widget/wedding_edit_widget.dart';
import 'package:wedding_gift_app/models/wedding/wedding_model.dart';
import 'package:wedding_gift_app/utils/app_translations.dart';

void main() {
  testWidgets('guest form renders on a compact screen', (tester) async {
    await _openForm(tester, GuestAddWidget(onSubmit: (_) async {}));

    expect(find.text('Add guest'), findsOneWidget);
    expect(find.text('Save guest'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('guest form uses the selected Khmer locale', (tester) async {
    await _openForm(
      tester,
      GuestAddWidget(onSubmit: (_) async {}),
      locale: const Locale('km'),
    );

    expect(find.text('បន្ថែមភ្ញៀវ'), findsOneWidget);
    expect(find.text('រក្សាទុកភ្ញៀវ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('gift form renders on a compact screen', (tester) async {
    await _openForm(tester, GiftAddWidget(onSubmit: (_) async {}));

    expect(find.text('Add gift'), findsOneWidget);
    expect(find.text('Save gift'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wedding form renders on a compact screen', (tester) async {
    await _openForm(tester, WeddingAddWidget(onSubmit: (_) async {}));

    expect(find.text('Add wedding'), findsOneWidget);
    expect(find.text('Save wedding'), findsOneWidget);
    expect(find.text('Contact phone *'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('edit wedding form pre-fills and preserves existing image', (
    tester,
  ) async {
    final wedding = WeddingModel(
      id: 'wedding-1',
      userId: 'user-1',
      weddingTitle: 'Sample Wedding',
      groomName: 'Alex',
      brideName: 'Sam',
      weddingDate: DateTime(2026, 12, 1),
      weddingLocation: 'Phnom Penh',
      contactPhone: '012345678',
      description: 'Bring flowers',
      coverImageUrl: 'https://example.com/wedding.jpg',
    );
    WeddingModel? submitted;

    await _openForm(
      tester,
      WeddingEditWidget(
        wedding: wedding,
        onSubmit: (model) async => submitted = model,
      ),
    );

    final fields = tester.widgetList<TextFormField>(find.byType(TextFormField));
    expect(fields.elementAt(1).controller?.text, 'Alex');
    expect(fields.elementAt(2).controller?.text, 'Sam');
    expect(fields.elementAt(5).controller?.text, 'Phnom Penh');
    expect(fields.elementAt(6).controller?.text, '012345678');
    expect(fields.elementAt(7).controller?.text, 'Bring flowers');
    expect(find.text('Current cover photo'), findsOneWidget);

    await tester.tap(find.text('Update wedding'));
    await tester.pumpAndSettle();

    expect(submitted?.contactPhone, '012345678');
    expect(submitted?.coverImageUrl, 'https://example.com/wedding.jpg');
    expect(tester.takeException(), isNull);
  });
}

Future<void> _openForm(
  WidgetTester tester,
  Widget form, {
  Locale locale = const Locale('en'),
}) async {
  await tester.binding.setSurfaceSize(const Size(360, 640));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    GetMaterialApp(
      translations: AppTranslations(),
      locale: locale,
      fallbackLocale: const Locale('en'),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () =>
                  showDialog<void>(context: context, builder: (_) => form),
              child: const Text('Open form'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open form'));
  await tester.pumpAndSettle();
}
