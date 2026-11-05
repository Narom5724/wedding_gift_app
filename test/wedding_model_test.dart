import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_gift_app/models/wedding/wedding_model.dart';

void main() {
  test(
    'contact phone is retained when reading and writing wedding records',
    () {
      final wedding = WeddingModel(
        id: 'wedding-1',
        userId: 'user-1',
        weddingTitle: 'Sample Wedding',
        groomName: 'Alex',
        brideName: 'Sam',
        weddingDate: DateTime(2026, 12, 1),
        contactPhone: '012345678',
      );

      final restored = WeddingModel.fromMap(wedding.toMap(), id: wedding.id);

      expect(restored.contactPhone, '012345678');
      expect(
        restored.copyWith(contactPhone: '098765432').contactPhone,
        '098765432',
      );
    },
  );

  test('older wedding records default missing contact phone to empty', () {
    final wedding = WeddingModel.fromMap({
      'userId': 'user-1',
      'weddingTitle': 'Sample Wedding',
      'groomName': 'Alex',
      'brideName': 'Sam',
      'weddingDate': DateTime(2026, 12, 1),
    });

    expect(wedding.contactPhone, isEmpty);
  });
}
