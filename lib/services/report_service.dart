import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/report/gift_report_model.dart';
import '../utils/currency_helper.dart';

class ReportService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  Future<List<GiftReportModel>> fetchReports() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return <GiftReportModel>[];
    }

    final weddingSnapshot = await _firestore
        .collection('weddings')
        .where('userId', isEqualTo: userId)
        .get();

    final giftsSnapshot = await _firestore
        .collection('gifts')
        .where('userId', isEqualTo: userId)
        .get();

    final weddingMap = <String, String>{
      for (final doc in weddingSnapshot.docs) doc.id: _weddingTitle(doc.data()),
    };

    final groupedAmounts = <String, Map<String, num>>{
      for (final wedding in weddingSnapshot.docs)
        wedding.id: {'USD': 0, 'KHR': 0, 'count': 0},
    };
    for (final doc in giftsSnapshot.docs) {
      final weddingId = (doc.data()['weddingId'] ?? '').toString();
      final amount = (doc.data()['amount'] as num?)?.toDouble() ?? 0;
      final currency = CurrencyHelper.normalize(
        (doc.data()['currency'] ?? 'USD').toString(),
      );
      final entry = groupedAmounts.putIfAbsent(
        weddingId,
        () => {'USD': 0, 'KHR': 0},
      );
      if (currency == CurrencyHelper.usd) {
        entry['USD'] = (entry['USD'] ?? 0) + amount;
      } else if (currency == CurrencyHelper.khr) {
        entry['KHR'] = (entry['KHR'] ?? 0) + amount;
      }
      entry['count'] = (entry['count'] ?? 0) + 1;
    }

    final reports = <GiftReportModel>[];
    for (final entry in groupedAmounts.entries) {
      final weddingName = weddingMap[entry.key];
      reports.add(
        GiftReportModel(
          weddingName: weddingName ?? 'Wedding',
          giftCount: (entry.value['count'] ?? 0).toInt(),
          totalUsd: (entry.value['USD'] ?? 0).toInt(),
          totalKhr: (entry.value['KHR'] ?? 0).toInt(),
        ),
      );
    }

    return reports;
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
}
