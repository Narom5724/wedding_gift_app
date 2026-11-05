import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_gift_app/models/gift/gift_model.dart';
import 'package:wedding_gift_app/models/guest/guest_model.dart';
import 'package:wedding_gift_app/models/wedding/wedding_model.dart';
import 'package:wedding_gift_app/screen/gift/widget/gift_list_widget.dart';
import 'package:wedding_gift_app/screen/guest/widget/guest_list_widget.dart';
import 'package:wedding_gift_app/screen/wedding/widget/wedding_data_table.dart';
import 'package:wedding_gift_app/screen/wedding/widget/wedding_list_widget.dart';

void main() {
  for (final width in [390.0, 1000.0]) {
    final isWide = width >= 600;
    testWidgets('record lists adapt at width $width', (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(child: _weddingList()),
                Expanded(child: _guestList()),
                Expanded(child: _giftList()),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DataTable), isWide ? findsNWidgets(2) : findsNothing);
      expect(
        find.byType(WeddingDataTable),
        isWide ? findsOneWidget : findsNothing,
      );
      expect(find.byType(Card), isWide ? findsNothing : findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });
  }
}

Widget _weddingList() {
  return WeddingListWidget(
    weddings: [
      WeddingModel(
        id: 'wedding-1',
        userId: 'user-1',
        weddingTitle: 'Sample Wedding',
        groomName: 'Alex',
        brideName: 'Sam',
        weddingDate: DateTime(2026, 12, 1),
      ),
    ],
    isLoading: false,
    onRefresh: () async {},
    onClearFilters: () {},
    onAddWedding: () {},
    onView: (_) {},
    onEdit: (_) {},
    onDelete: (_) async {},
  );
}

Widget _guestList() {
  return GuestListWidget(
    guests: [
      GuestModel(
        id: 'guest-1',
        userId: 'user-1',
        weddingId: 'wedding-1',
        fullName: 'Taylor Guest',
        phone: '123456789',
        relationship: 'Friend',
      ),
    ],
    isLoading: false,
    errorMessage: '',
    onRefresh: () async {},
    onEdit: (_) {},
    onDelete: (_) async {},
  );
}

Widget _giftList() {
  return GiftListWidget(
    gifts: [
      GiftModel(
        id: 'gift-1',
        userId: 'user-1',
        weddingId: 'wedding-1',
        guestId: 'guest-1',
        amount: 25,
        currency: 'USD',
        receivedDate: DateTime(2026, 11, 4),
      ),
    ],
    isLoading: false,
    errorMessage: '',
    onRefresh: () async {},
    onEdit: (_) {},
    onDelete: (_) async {},
  );
}
