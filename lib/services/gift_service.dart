import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';

import '../models/gift/gift_model.dart';

class GiftService {
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
        message: 'Please sign in before managing gifts.',
      );
    }
    return uid;
  }

  Future<List<GiftModel>> fetchGifts({
    String query = '',
    DateTime? dateFilter,
  }) async {
    final uid = _uid;

    Query<Map<String, dynamic>> firestoreQuery = _firestore
        .collection('gifts')
        .where('userId', isEqualTo: uid);

    final snapshot = await firestoreQuery.get();
    final gifts = snapshot.docs
        .map((doc) => GiftModel.fromMap(doc.data(), id: doc.id))
        .toList();
    gifts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final normalizedQuery = query.trim().toLowerCase();
    final weddingSearchValues = <String, List<String>>{};
    final guestSearchValues = <String, List<String>>{};
    if (normalizedQuery.isNotEmpty) {
      final relatedRecords = await Future.wait([
        _firestore.collection('weddings').where('userId', isEqualTo: uid).get(),
        _firestore.collection('guests').where('userId', isEqualTo: uid).get(),
      ]);

      for (final document in relatedRecords[0].docs) {
        final data = document.data();
        weddingSearchValues[document.id] = [
          (data['weddingTitle'] ?? '').toString(),
          (data['groomName'] ?? '').toString(),
          (data['brideName'] ?? '').toString(),
          (data['weddingLocation'] ?? data['location'] ?? '').toString(),
          if (data['weddingDate'] is Timestamp)
            DateFormat(
              'yyyy-MM-dd',
            ).format((data['weddingDate'] as Timestamp).toDate()),
        ];
      }

      for (final document in relatedRecords[1].docs) {
        final data = document.data();
        guestSearchValues[document.id] = [
          (data['fullName'] ?? '').toString(),
          (data['phone'] ?? '').toString(),
          (data['relationship'] ?? '').toString(),
        ];
      }
    }

    final filtered = gifts.where((gift) {
      final matchesQuery = gift.matchesSearch(
        normalizedQuery,
        relatedNames: [
          ...?weddingSearchValues[gift.weddingId],
          ...?guestSearchValues[gift.guestId],
        ],
      );
      final matchesDate =
          dateFilter == null ||
          (gift.receivedDate.year == dateFilter.year &&
              gift.receivedDate.month == dateFilter.month &&
              gift.receivedDate.day == dateFilter.day);
      return matchesQuery && matchesDate;
    }).toList();

    return filtered;
  }

  Future<void> createGift(GiftModel gift) async {
    final uid = _uid;

    if (gift.amount <= 0) {
      throw ArgumentError('Gift amount must be greater than zero.');
    }

    await _validateWeddingOwnership(uid, gift.weddingId);
    final guestDoc = await _firestore
        .collection('guests')
        .doc(gift.guestId)
        .get();
    if (!guestDoc.exists || guestDoc.data()?['userId'] != uid) {
      throw StateError('Guest not found for the current user.');
    }

    if (guestDoc.data()?['weddingId'] != gift.weddingId) {
      throw StateError(
        'Selected guest does not belong to the selected wedding.',
      );
    }

    final id = gift.id.isEmpty
        ? _firestore.collection('gifts').doc().id
        : gift.id;
    final record = gift
        .copyWith(id: id, userId: uid, updatedAt: DateTime.now())
        .toMap(forCreate: true);

    await _firestore
        .collection('gifts')
        .doc(id)
        .set(record, SetOptions(merge: true));
  }

  Future<void> updateGift(GiftModel gift) async {
    final uid = _uid;
    if (gift.id.isEmpty) {
      throw ArgumentError.value(gift.id, 'gift.id', 'Cannot be empty.');
    }
    if (gift.amount <= 0) {
      throw ArgumentError('Gift amount must be greater than zero.');
    }

    await _validateWeddingOwnership(uid, gift.weddingId);
    final existing = await _firestore.collection('gifts').doc(gift.id).get();
    if (!existing.exists || existing.data()?['userId'] != uid) {
      throw StateError('Gift not found for the current user.');
    }
    final guest = await _firestore.collection('guests').doc(gift.guestId).get();
    if (!guest.exists || guest.data()?['userId'] != uid) {
      throw StateError('Guest not found for the current user.');
    }
    if (guest.data()?['weddingId'] != gift.weddingId) {
      throw StateError(
        'Selected guest does not belong to the selected wedding.',
      );
    }

    final record = gift
        .copyWith(userId: uid, updatedAt: DateTime.now())
        .toMap();
    await _firestore.collection('gifts').doc(gift.id).update(record);
  }

  Future<void> deleteGift(String giftId) async {
    final uid = _uid;
    if (giftId.isEmpty) {
      throw ArgumentError.value(giftId, 'giftId', 'Cannot be empty.');
    }
    final gift = await _firestore.collection('gifts').doc(giftId).get();
    if (!gift.exists || gift.data()?['userId'] != uid) {
      throw StateError('Gift not found for the current user.');
    }
    await _firestore.collection('gifts').doc(giftId).delete();
  }

  Future<void> _validateWeddingOwnership(String uid, String weddingId) async {
    if (weddingId.isEmpty) {
      throw ArgumentError.value(weddingId, 'weddingId', 'Cannot be empty.');
    }

    final wedding = await _firestore
        .collection('weddings')
        .doc(weddingId)
        .get();
    if (!wedding.exists || wedding.data()?['userId'] != uid) {
      throw StateError('Wedding not found for the current user.');
    }
  }
}
