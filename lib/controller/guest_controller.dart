import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:wedding_gift_app/models/guest/guest_model.dart';
import 'package:wedding_gift_app/services/guest_service.dart';
import 'package:wedding_gift_app/utils/firestore_error_message.dart';

class GuestController extends GetxController {
  GuestController([GuestService? service])
    : _service = service ?? GuestService();

  final GuestService _service;
  final guestList = <GuestModel>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final searchText = ''.obs;
  final selectedWeddingId = ''.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadGuests();
  }

  Future<void> loadGuests({String? weddingId}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _service.fetchGuests(
        weddingId: weddingId ?? selectedWeddingId.value,
        query: searchText.value,
      );
      guestList.assignAll(data);
    } catch (error, stackTrace) {
      errorMessage.value = firestoreErrorMessage(
        error,
        operation: 'load guests',
      );
      debugPrint('Unable to load guests: $error\n$stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createGuest(GuestModel guest) async {
    await _saveGuest(() => _service.createGuest(guest));
  }

  Future<void> updateGuest(GuestModel guest) async {
    await _saveGuest(() => _service.updateGuest(guest));
  }

  Future<void> deleteGuest(String guestId) async {
    if (isSaving.value) return;
    isSaving.value = true;
    errorMessage.value = '';
    try {
      await _service.deleteGuest(guestId);
      await loadGuests();
    } catch (error, stackTrace) {
      errorMessage.value = firestoreErrorMessage(
        error,
        operation: 'delete guest',
      );
      debugPrint('Unable to delete guest: $error\n$stackTrace');
      rethrow;
    } finally {
      isSaving.value = false;
    }
  }

  void updateSearch(String value) {
    searchText.value = value;
    loadGuests();
  }

  Future<void> _saveGuest(Future<void> Function() save) async {
    if (isSaving.value) return;
    isSaving.value = true;
    errorMessage.value = '';
    try {
      await save();
      await loadGuests();
    } catch (error, stackTrace) {
      errorMessage.value = firestoreErrorMessage(
        error,
        operation: 'save guest',
      );
      debugPrint('Unable to save guest: $error\n$stackTrace');
      rethrow;
    } finally {
      isSaving.value = false;
    }
  }
}
