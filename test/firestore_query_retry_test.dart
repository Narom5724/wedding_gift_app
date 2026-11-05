import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_gift_app/controller/gift_controller.dart';
import 'package:wedding_gift_app/controller/guest_controller.dart';
import 'package:wedding_gift_app/models/gift/gift_model.dart';
import 'package:wedding_gift_app/models/guest/guest_model.dart';
import 'package:wedding_gift_app/services/gift_service.dart';
import 'package:wedding_gift_app/services/guest_service.dart';

void main() {
  test('guest query failure can be retried after index creation', () async {
    final service = _RetryGuestService();
    final controller = GuestController(service);

    await controller.loadGuests();
    expect(controller.isLoading.value, isFalse);
    expect(controller.errorMessage.value, contains('composite index'));

    service.fail = false;
    await controller.loadGuests();
    expect(controller.isLoading.value, isFalse);
    expect(controller.errorMessage.value, isEmpty);
  });

  test('gift query failure can be retried after index creation', () async {
    final service = _RetryGiftService();
    final controller = GiftController(service);

    await controller.loadGifts();
    expect(controller.isLoading.value, isFalse);
    expect(controller.errorMessage.value, contains('composite index'));

    service.fail = false;
    await controller.loadGifts();
    expect(controller.isLoading.value, isFalse);
    expect(controller.errorMessage.value, isEmpty);
  });
}

class _RetryGuestService extends GuestService {
  bool fail = true;

  @override
  Future<List<GuestModel>> fetchGuests({
    String weddingId = '',
    String query = '',
    String relationship = '',
  }) async {
    if (fail) throw _indexException();
    return [];
  }
}

class _RetryGiftService extends GiftService {
  bool fail = true;

  @override
  Future<List<GiftModel>> fetchGifts({
    String weddingId = '',
    String query = '',
    DateTime? dateFilter,
  }) async {
    if (fail) throw _indexException();
    return [];
  }
}

FirebaseException _indexException() {
  return FirebaseException(
    plugin: 'cloud_firestore',
    code: 'failed-precondition',
    message: 'The query requires an index.',
  );
}
