import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/currency_helper.dart';

class DashboardService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  Future<Map<String, dynamic>> fetchSummary() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return {
        'totalWeddings': 0,
        'totalGuests': 0,
        'totalGiftRecords': 0,
        'totalUsd': 0,
        'totalKhr': 0,
      };
    }

    final weddingSnapshot = await _firestore
        .collection('weddings')
        .where('userId', isEqualTo: userId)
        .get();
    final guestSnapshot = await _firestore
        .collection('guests')
        .where('userId', isEqualTo: userId)
        .get();
    final giftSnapshot = await _firestore
        .collection('gifts')
        .where('userId', isEqualTo: userId)
        .get();

    final today = DateTime.now();
    final weddingNames = <String, String>{
      for (final doc in weddingSnapshot.docs) doc.id: _weddingTitle(doc.data()),
    };
    final guestNames = <String, String>{
      for (final doc in guestSnapshot.docs)
        doc.id: (doc.data()['fullName'] ?? 'Guest').toString(),
    };
    final upcomingWeddings =
        weddingSnapshot.docs
            .map((doc) {
              final data = doc.data();
              final date = _dateTimeFrom(data['weddingDate']);
              return (date: date, title: weddingNames[doc.id]!);
            })
            .where(
              (wedding) =>
                  wedding.date != null &&
                  !DateTime(
                    wedding.date!.year,
                    wedding.date!.month,
                    wedding.date!.day,
                  ).isBefore(DateTime(today.year, today.month, today.day)),
            )
            .toList()
          ..sort((a, b) => a.date!.compareTo(b.date!));

    var totalUsd = 0.0;
    var totalKhr = 0.0;
    for (final doc in giftSnapshot.docs) {
      final amount = (doc.data()['amount'] as num?)?.toDouble() ?? 0;
      final currency = CurrencyHelper.normalize(
        (doc.data()['currency'] ?? 'USD').toString(),
      );
      if (currency == CurrencyHelper.usd) {
        totalUsd += amount;
      } else if (currency == CurrencyHelper.khr) {
        totalKhr += amount;
      }
    }

    return {
      'totalWeddings': weddingSnapshot.docs.length,
      'totalGuests': guestSnapshot.docs.length,
      'totalGiftRecords': giftSnapshot.docs.length,
      'totalUsd': totalUsd,
      'totalKhr': totalKhr,
      'upcomingWeddings': upcomingWeddings
          .map((wedding) => wedding.title)
          .toList(),
      'weddingNames': weddingNames,
      'guestNames': guestNames,
    };
  }

  String _weddingTitle(Map<String, dynamic> data) {
    final title = (data['weddingTitle'] ?? '').toString();
    if (title.isNotEmpty) return title;
    final couple = [
      (data['groomName'] ?? '').toString(),
      (data['brideName'] ?? '').toString(),
    ].where((name) => name.isNotEmpty).join(' & ');
    return couple.isEmpty ? 'Wedding' : couple;
  }

  DateTime? _dateTimeFrom(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
