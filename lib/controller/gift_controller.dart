import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:wedding_gift_app/models/gift/gift_model.dart';
import 'package:wedding_gift_app/models/guest/guest_model.dart';
import 'package:wedding_gift_app/models/wedding/wedding_model.dart';
import 'package:wedding_gift_app/services/gift_service.dart';
import 'package:wedding_gift_app/services/guest_service.dart';
import 'package:wedding_gift_app/services/wedding_service.dart';
import 'package:wedding_gift_app/utils/firestore_error_message.dart';

class GiftController extends GetxController {
  GiftController([
    GiftService? service,
    WeddingService? weddingService,
    GuestService? guestService,
  ]) : _service = service ?? GiftService(),
       _weddingService = weddingService ?? WeddingService(),
       _guestService = guestService ?? GuestService();

  final GiftService _service;
  final WeddingService _weddingService;
  final GuestService _guestService;
  final gifts = <GiftModel>[].obs;
  final weddingNames = <String, String>{}.obs;
  final guestNames = <String, String>{}.obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final searchText = ''.obs;
  final selectedDate = Rxn<DateTime>();
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadGifts();
  }

  Future<void> loadRelatedNames() async {
    try {
      final weddings = await _weddingService.fetchWeddings();
      final guests = await _guestService.fetchGuests();
      weddingNames.assignAll({
        for (final WeddingModel wedding in weddings) wedding.id: wedding.title,
      });
      guestNames.assignAll({
        for (final GuestModel guest in guests) guest.id: guest.fullName,
      });
    } catch (error, stackTrace) {
      debugPrint('Unable to load gift relationship names: $error\n$stackTrace');
    }
  }

  Future<void> loadGifts() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _service.fetchGifts(
        query: searchText.value,
        dateFilter: selectedDate.value,
      );
      gifts.assignAll(data);
    } catch (error, stackTrace) {
      errorMessage.value = firestoreErrorMessage(
        error,
        operation: 'load gifts',
      );
      debugPrint('Unable to load gifts: $error\n$stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createGift(GiftModel gift) async {
    await _saveGift(() => _service.createGift(gift));
  }

  Future<void> updateGift(GiftModel gift) async {
    await _saveGift(() => _service.updateGift(gift));
  }

  Future<void> deleteGift(String giftId) async {
    if (isSaving.value) return;
    isSaving.value = true;
    errorMessage.value = '';
    try {
      await _service.deleteGift(giftId);
      await loadGifts();
    } catch (error, stackTrace) {
      errorMessage.value = firestoreErrorMessage(
        error,
        operation: 'delete gift',
      );
      debugPrint('Unable to delete gift: $error\n$stackTrace');
      rethrow;
    } finally {
      isSaving.value = false;
    }
  }

  void updateSearch(String value) {
    searchText.value = value;
    loadGifts();
  }

  void filterByDate(DateTime? value) {
    selectedDate.value = value;
    loadGifts();
  }

  Future<void> _saveGift(Future<void> Function() save) async {
    if (isSaving.value) return;
    isSaving.value = true;
    errorMessage.value = '';
    try {
      await save();
      await loadGifts();
    } catch (error, stackTrace) {
      errorMessage.value = firestoreErrorMessage(error, operation: 'save gift');
      debugPrint('Unable to save gift: $error\n$stackTrace');
      rethrow;
    } finally {
      isSaving.value = false;
    }
  }
}
