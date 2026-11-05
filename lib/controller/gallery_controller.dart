import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:wedding_gift_app/models/gallery/gallery_image.dart';
import 'package:wedding_gift_app/services/storage_service.dart';

class GalleryController extends GetxController {
  static const _pageSize = 50;

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;
  final images = <GalleryImage>[].obs;
  final isLoading = false.obs;
  final hasMore = true.obs;
  final errorMessage = RxnString();

  final List<GalleryImage> _entries = [];
  DocumentSnapshot<Map<String, dynamic>>? _lastDocument;
  bool _requestInProgress = false;

  @override
  void onInit() {
    super.onInit();
    loadGallery();
  }

  Future<void> loadGallery() async {
    await refreshGallery();
  }

  Future<void> refreshGallery() async {
    if (_requestInProgress) return;
    _entries.clear();
    images.clear();
    _lastDocument = null;
    hasMore.value = true;
    errorMessage.value = null;
    await loadMore();
  }

  Future<void> loadMore() async {
    if (_requestInProgress || !hasMore.value) return;

    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      images.clear();
      hasMore.value = false;
      return;
    }

    _requestInProgress = true;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      var query = _firestore
          .collection('gallery')
          .where('userId', isEqualTo: userId)
          .limit(_pageSize);
      final lastDocument = _lastDocument;
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        _entries.addAll(
          snapshot.docs
              .map((doc) {
                final data = doc.data();
                return GalleryImage(
                  imageUrl: (data['imageUrl'] ?? '').toString(),
                  createdAt: _createdAt(data['createdAt']),
                );
              })
              .where((entry) => entry.imageUrl.isNotEmpty),
        );
        _entries.sort((a, b) {
          if (a.createdAt == null) return b.createdAt == null ? 0 : 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        images.assignAll(_entries);
      }
      hasMore.value = snapshot.docs.length == _pageSize;
    } catch (error, stackTrace) {
      errorMessage.value = error.toString();
      debugPrint('Unable to load gallery: $error\n$stackTrace');
    } finally {
      _requestInProgress = false;
      isLoading.value = false;
    }
  }

  DateTime? _createdAt(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  Future<void> addImage(String imageUrl, {String storagePath = ''}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw StateError('User not authenticated.');
    }

    await _firestore.collection('gallery').add({
      'userId': userId,
      'imageUrl': imageUrl,
      'storagePath': storagePath,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await refreshGallery();
  }

  Future<void> deleteImage(String imageUrl) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw StateError('User not authenticated.');
    }

    final snapshot = await _firestore
        .collection('gallery')
        .where('userId', isEqualTo: userId)
        .where('imageUrl', isEqualTo: imageUrl)
        .limit(1)
        .get();

    for (final doc in snapshot.docs) {
      final storagePath = (doc.data()['storagePath'] ?? '').toString();
      if (storagePath.isNotEmpty) {
        await StorageService().deleteImage(storagePath);
      }
      await doc.reference.delete();
    }
    _entries.removeWhere((entry) => entry.imageUrl == imageUrl);
    images.assignAll(_entries);
  }
}
