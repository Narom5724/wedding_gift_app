import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:wedding_gift_app/models/wedding/wedding_model.dart';
import 'package:wedding_gift_app/services/wedding_service.dart';

class WeddingController extends GetxController {
  WeddingController(this._service);

  final WeddingService _service;
  final weddings = <WeddingModel>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final searchText = ''.obs;
  final selectedDate = Rxn<DateTime>();
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadWeddings();
  }

  Future<void> loadWeddings() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _service.fetchWeddings(
        query: searchText.value,
        dateFilter: selectedDate.value,
      );
      weddings.assignAll(data);
    } catch (error, stackTrace) {
      errorMessage.value = _messageFor(error);
      debugPrint('Unable to load weddings: $error\n$stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createWedding(WeddingModel wedding) async {
    await _saveWedding(() => _service.createWedding(wedding));
  }

  Future<void> updateWedding(WeddingModel wedding) async {
    await _saveWedding(() => _service.updateWedding(wedding));
  }

  Future<void> deleteWedding(String weddingId) async {
    try {
      await _service.deleteWedding(weddingId);
      await loadWeddings();
    } catch (error, stackTrace) {
      errorMessage.value = _messageFor(error);
      debugPrint('Unable to delete wedding: $error\n$stackTrace');
      rethrow;
    }
  }

  void updateSearch(String value) {
    searchText.value = value;
    loadWeddings();
  }

  void clearFilters() {
    searchText.value = '';
    selectedDate.value = null;
    loadWeddings();
  }

  void filterByDate(DateTime? date) {
    selectedDate.value = date;
    loadWeddings();
  }

  Future<void> _saveWedding(Future<void> Function() save) async {
    if (isSaving.value) return;

    isSaving.value = true;
    errorMessage.value = '';
    try {
      await save().timeout(const Duration(seconds: 30));
      // Refresh the list without keeping the form's Save button spinning
      // while a separate read request is pending.
      unawaited(loadWeddings());
    } catch (error, stackTrace) {
      errorMessage.value = _messageFor(error);
      debugPrint('Unable to save wedding: $error\n$stackTrace');
      rethrow;
    } finally {
      isSaving.value = false;
    }
  }

  String _messageFor(Object error) {
    if (error is TimeoutException) {
      return 'wedding_connection_unavailable'.tr;
    }
    if (error is FirebaseException) {
      return switch (error.code) {
        'unauthenticated' => 'unauthenticated_wedding'.tr,
        'permission-denied' => 'wedding_permission_denied'.tr,
        'unavailable' => 'wedding_connection_unavailable'.tr,
        'failed-precondition' => 'wedding_service_not_ready'.tr,
        'not-found' => 'wedding_record_not_found'.tr,
        _ => 'wedding_operation_failed_message'.tr,
      };
    }
    if (error is StateError) {
      final message = error.message.toString().toLowerCase();
      if (message.contains('guest')) return 'wedding_has_guests'.tr;
      if (message.contains('gift')) return 'wedding_has_gifts'.tr;
    }
    return 'wedding_operation_failed_message'.tr;
  }
}
