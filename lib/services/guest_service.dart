import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/guest/guest_model.dart';

class GuestService {
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
        message: 'Please sign in before managing guests.',
      );
    }
    return uid;
  }

  Future<List<GuestModel>> fetchGuests({
    String weddingId = '',
    String query = '',
  }) async {
    final uid = _uid;

    Query<Map<String, dynamic>> firestoreQuery = _firestore
        .collection('guests')
        .where('userId', isEqualTo: uid);

    if (weddingId.isNotEmpty) {
      firestoreQuery = firestoreQuery.where('weddingId', isEqualTo: weddingId);
    }

    final snapshot = await firestoreQuery.get();
    var guests = snapshot.docs
        .map((doc) => GuestModel.fromMap(doc.data(), id: doc.id))
        .toList();
    guests.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final normalizedQuery = query.trim().toLowerCase();
    guests = guests.where((guest) {
      final matchesQuery =
          normalizedQuery.isEmpty ||
          guest.fullName.toLowerCase().contains(normalizedQuery) ||
          guest.phone.toLowerCase().contains(normalizedQuery) ||
          guest.address.toLowerCase().contains(normalizedQuery) ||
          guest.relationship.toLowerCase().contains(normalizedQuery) ||
          guest.notes.toLowerCase().contains(normalizedQuery);
      return matchesQuery;
    }).toList();

    return guests;
  }

  Future<void> createGuest(GuestModel guest) async {
    final uid = _uid;
    await _validateWeddingOwnership(uid, guest.weddingId);

    final id = guest.id.isEmpty
        ? _firestore.collection('guests').doc().id
        : guest.id;
    final record = guest
        .copyWith(id: id, userId: uid, updatedAt: DateTime.now())
        .toMap(forCreate: true);

    await _firestore
        .collection('guests')
        .doc(id)
        .set(record, SetOptions(merge: true));
  }

  Future<void> updateGuest(GuestModel guest) async {
    final uid = _uid;
    if (guest.id.isEmpty) {
      throw ArgumentError.value(guest.id, 'guest.id', 'Cannot be empty.');
    }
    await _validateWeddingOwnership(uid, guest.weddingId);
    final existing = await _firestore.collection('guests').doc(guest.id).get();
    if (!existing.exists || existing.data()?['userId'] != uid) {
      throw StateError('Guest not found for the current user.');
    }
    final record = guest
        .copyWith(userId: uid, updatedAt: DateTime.now())
        .toMap();
    await _firestore.collection('guests').doc(guest.id).update(record);
  }

  Future<void> deleteGuest(String guestId) async {
    final uid = _uid;
    if (guestId.isEmpty) {
      throw ArgumentError.value(guestId, 'guestId', 'Cannot be empty.');
    }
    final guest = await _firestore.collection('guests').doc(guestId).get();
    if (!guest.exists || guest.data()?['userId'] != uid) {
      throw StateError('Guest not found for the current user.');
    }
    final giftCount = await _firestore
        .collection('gifts')
        .where('userId', isEqualTo: uid)
        .where('guestId', isEqualTo: guestId)
        .limit(1)
        .get();

    if (giftCount.docs.isNotEmpty) {
      throw StateError('This guest has gift records. Delete those first.');
    }

    await _firestore.collection('guests').doc(guestId).delete();
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
