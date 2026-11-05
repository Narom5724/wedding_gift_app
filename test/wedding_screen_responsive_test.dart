import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:wedding_gift_app/controller/wedding_controller.dart';
import 'package:wedding_gift_app/models/wedding/wedding_model.dart';
import 'package:wedding_gift_app/screen/wedding/wedding_screen.dart';
import 'package:wedding_gift_app/screen/wedding/widget/wedding_data_table.dart';
import 'package:wedding_gift_app/services/wedding_service.dart';
import 'package:wedding_gift_app/utils/app_translations.dart';

void main() {
  for (final width in [320.0, 390.0, 599.0, 600.0, 800.0, 1000.0, 1440.0]) {
    final isWide = width >= 600;
    testWidgets('wedding screen adapts at width $width', (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      Get.reset();
      addTearDown(Get.reset);
      final service = _FakeWeddingService();
      Get.put(WeddingController(service));

      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('en'),
          fallbackLocale: const Locale('en'),
          home: const WeddingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), isWide ? findsNothing : findsOneWidget);
      expect(
        find.byType(WeddingDataTable),
        isWide ? findsOneWidget : findsNothing,
      );
      expect(find.byType(Card), isWide ? findsNothing : findsOneWidget);
      expect(find.text('1 WEDDING'), findsOneWidget);
      expect(
        width < 400 ? find.byTooltip('Add wedding') : find.text('Add wedding'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      if (width == 390) {
        await tester.tap(find.byType(PopupMenuButton<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('View details'));
        await tester.pumpAndSettle();
        expect(find.text('Sample Wedding'), findsNWidgets(2));
        expect(find.text('Alex & Sam'), findsNWidgets(2));
        await tester.tap(find.byTooltip('Close'));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(PopupMenuButton<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();
        expect(service.deletedWeddingId, 'wedding-1');
        await tester.pump(const Duration(seconds: 4));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'no matching record');
        await tester.pumpAndSettle();
        expect(find.text('No weddings match these filters'), findsOneWidget);
        await tester.tap(find.text('Clear search'));
        await tester.pumpAndSettle();
        expect(find.text('Sample Wedding'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  }
}

class _FakeWeddingService extends WeddingService {
  String? deletedWeddingId;

  @override
  Future<List<WeddingModel>> fetchWeddings({
    String query = '',
    DateTime? dateFilter,
  }) async {
    final weddings = [
      WeddingModel(
        id: 'wedding-1',
        userId: 'user-1',
        weddingTitle: 'Sample Wedding',
        groomName: 'Alex',
        brideName: 'Sam',
        weddingDate: DateTime(2026, 12, 1),
      ),
    ];
    if (query.isEmpty) return weddings;
    final normalizedQuery = query.toLowerCase();
    return weddings
        .where(
          (wedding) =>
              wedding.title.toLowerCase().contains(normalizedQuery) ||
              wedding.groomName.toLowerCase().contains(normalizedQuery) ||
              wedding.brideName.toLowerCase().contains(normalizedQuery) ||
              wedding.weddingLocation.toLowerCase().contains(normalizedQuery),
        )
        .toList();
  }

  @override
  Future<void> deleteWedding(String weddingId) async {
    deletedWeddingId = weddingId;
  }
}
