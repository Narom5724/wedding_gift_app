import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/wedding/wedding_model.dart';

class WeddingService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  String get _uid {
    if (Firebase.apps.isEmpty) {
      throw StateError('Firebase is not initialized.');
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw FirebaseException(
        plugin: 'firebase_auth',
        code: 'unauthenticated',
        message: 'Please sign in before managing weddings.',
      );
    }
    return uid;
  }

  Future<List<WeddingModel>> fetchWeddings({
    String query = '',
    DateTime? dateFilter,
  }) async {
    final uid = _uid;
    final snapshot = await _firestore
        .collection('weddings')
        .where('userId', isEqualTo: uid)
        .get();
    final weddings = snapshot.docs
        .map((doc) => WeddingModel.fromMap(doc.data(), id: doc.id))
        .toList();
    weddings.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final normalizedQuery = query.trim().toLowerCase();
    final filtered = weddings.where((wedding) {
      final matchesQuery =
          normalizedQuery.isEmpty ||
          wedding.title.toLowerCase().contains(normalizedQuery) ||
          wedding.groomName.toLowerCase().contains(normalizedQuery) ||
          wedding.brideName.toLowerCase().contains(normalizedQuery) ||
          wedding.weddingLocation.toLowerCase().contains(normalizedQuery) ||
          wedding.contactPhone.toLowerCase().contains(normalizedQuery);
      final matchesDate =
          dateFilter == null ||
          (wedding.weddingDate.year == dateFilter.year &&
              wedding.weddingDate.month == dateFilter.month &&
              wedding.weddingDate.day == dateFilter.day);
      return matchesQuery && matchesDate;
    }).toList();

    return filtered;
  }

  Future<WeddingModel?> fetchWeddingById(String id) async {
    final uid = _uid;
    final doc = await _firestore.collection('weddings').doc(id).get();
    final data = doc.data();
    if (!doc.exists || data == null || data['userId'] != uid) return null;
    return WeddingModel.fromMap(data, id: doc.id);
  }

  Future<void> createWedding(WeddingModel wedding) async {
    final uid = _uid;
    final document = _firestore.collection('weddings').doc();
    final id = document.id;
    final record = wedding
        .copyWith(id: id, userId: uid, updatedAt: DateTime.now())
        .toMap(forCreate: true);

    await document.set(record);
  }

  Future<void> updateWedding(WeddingModel wedding) async {
    final uid = _uid;
    if (wedding.id.isEmpty) {
      throw ArgumentError.value(wedding.id, 'wedding.id', 'Cannot be empty.');
    }

    final record = wedding
        .copyWith(userId: uid, updatedAt: DateTime.now())
        .toMap();

    await _firestore.collection('weddings').doc(wedding.id).update(record);
  }

  Future<void> deleteWedding(String weddingId) async {
    final uid = _uid;
    if (weddingId.isEmpty) {
      throw ArgumentError.value(weddingId, 'weddingId', 'Cannot be empty.');
    }

    final guestCount = await _firestore
        .collection('guests')
        .where('userId', isEqualTo: uid)
        .where('weddingId', isEqualTo: weddingId)
        .limit(1)
        .get();

    if (guestCount.docs.isNotEmpty) {
      throw StateError('This wedding has guest records. Delete those first.');
    }

    final giftCount = await _firestore
        .collection('gifts')
        .where('userId', isEqualTo: uid)
        .where('weddingId', isEqualTo: weddingId)
        .limit(1)
        .get();

    if (giftCount.docs.isNotEmpty) {
      throw StateError('This wedding has gift records. Delete those first.');
    }

    await _firestore.collection('weddings').doc(weddingId).delete();
  }
}
