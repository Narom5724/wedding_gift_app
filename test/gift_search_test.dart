import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_gift_app/models/gift/gift_model.dart';

void main() {
  final gift = GiftModel(
    id: 'gift-123',
    userId: 'user-1',
    weddingId: 'wedding-456',
    guestId: 'guest-789',
    amount: 125.5,
    currency: 'USD',
    receivedDate: DateTime(2026, 11, 4),
    paymentMethod: 'Bank transfer',
    notes: 'Family contribution',
  );

  test('search matches gift IDs and form fields case-insensitively', () {
    expect(gift.matchesSearch('GIFT-123'), isTrue);
    expect(gift.matchesSearch('wedding-456'), isTrue);
    expect(gift.matchesSearch('guest-789'), isTrue);
    expect(gift.matchesSearch('125.5'), isTrue);
    expect(gift.matchesSearch('usd'), isTrue);
    expect(gift.matchesSearch('2026-11-04'), isTrue);
    expect(gift.matchesSearch('BANK TRANSFER'), isTrue);
    expect(gift.matchesSearch('family contribution'), isTrue);
  });

  test('search matches related wedding and guest form names', () {
    expect(
      gift.matchesSearch(
        'sokha',
        relatedNames: const ['Sokha Chea', 'Wedding in Phnom Penh'],
      ),
      isTrue,
    );
    expect(
      gift.matchesSearch(
        'phnom penh',
        relatedNames: const ['Sokha Chea', 'Wedding in Phnom Penh'],
      ),
      isTrue,
    );
  });

  test('empty search matches all gifts and unmatched values do not', () {
    expect(gift.matchesSearch('  '), isTrue);
    expect(gift.matchesSearch('not present'), isFalse);
  });
}
