import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:wedding_gift_app/models/gift/gift_model.dart';
import 'package:wedding_gift_app/models/guest/guest_model.dart';
import 'package:wedding_gift_app/models/report/gift_report_model.dart';
import 'package:wedding_gift_app/utils/currency_helper.dart';

class ReportService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  Future<GiftReportData> fetchReports() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return const GiftReportData();

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

    final weddingNames = <String, String>{};
    final weddingTotals = <String, _AmountTotals>{};
    for (final doc in weddingSnapshot.docs) {
      weddingNames[doc.id] = _weddingTitle(doc.data());
      weddingTotals[doc.id] = _AmountTotals();
    }

    final guests = <String, GuestModel>{};
    for (final doc in guestSnapshot.docs) {
      guests[doc.id] = GuestModel.fromMap(doc.data(), id: doc.id);
    }

    final guestTotals = <String, _AmountTotals>{};
    final dailyTotals = <DateTime, _AmountTotals>{};
    final monthlyTotals = <DateTime, _AmountTotals>{};
    var totalUsd = 0.0;
    var totalKhr = 0.0;
    LargestGiftReport? largestUsdGift;
    LargestGiftReport? largestKhrGift;

    for (final doc in giftSnapshot.docs) {
      final gift = GiftModel.fromMap(doc.data(), id: doc.id);
      final currency = CurrencyHelper.normalize(gift.currency);
      final weddingName = weddingNames[gift.weddingId] ?? 'Wedding';
      final guest = guests[gift.guestId];
      final guestName = guest?.fullName.isNotEmpty == true
          ? guest!.fullName
          : 'Unknown guest';

      final wedding = weddingTotals.putIfAbsent(
        gift.weddingId,
        _AmountTotals.new,
      );
      wedding.add(gift.amount, currency);

      final guestKey = '${gift.weddingId}|${gift.guestId}';
      guestTotals.putIfAbsent(guestKey, _AmountTotals.new).add(
        gift.amount,
        currency,
      );

      final day = DateTime(
        gift.receivedDate.year,
        gift.receivedDate.month,
        gift.receivedDate.day,
      );
      dailyTotals.putIfAbsent(day, _AmountTotals.new).add(
        gift.amount,
        currency,
      );
      final month = DateTime(gift.receivedDate.year, gift.receivedDate.month);
      monthlyTotals.putIfAbsent(month, _AmountTotals.new).add(
        gift.amount,
        currency,
      );

      if (currency == CurrencyHelper.usd) {
        totalUsd += gift.amount;
        if (largestUsdGift == null || gift.amount > largestUsdGift.amount) {
          largestUsdGift = LargestGiftReport(
            guestName: guestName,
            weddingName: weddingName,
            amount: gift.amount,
            currency: currency,
            date: gift.receivedDate,
          );
        }
      } else if (currency == CurrencyHelper.khr) {
        totalKhr += gift.amount;
        if (largestKhrGift == null || gift.amount > largestKhrGift.amount) {
          largestKhrGift = LargestGiftReport(
            guestName: guestName,
            weddingName: weddingName,
            amount: gift.amount,
            currency: currency,
            date: gift.receivedDate,
          );
        }
      }
    }

    final guestReports = <GuestGiftReport>[];
    for (final entry in guests.entries) {
      final guest = entry.value;
      final totals = guestTotals['${guest.weddingId}|${entry.key}'] ??
          _AmountTotals();
      guestReports.add(
        GuestGiftReport(
          guestName: guest.fullName,
          relationship: guest.relationship,
          phone: guest.phone,
          weddingName: weddingNames[guest.weddingId] ?? 'Wedding',
          giftCount: totals.count,
          totalUsd: totals.usd,
          totalKhr: totals.khr,
        ),
      );
    }
    guestReports.sort((a, b) {
      final byUsd = b.totalUsd.compareTo(a.totalUsd);
      return byUsd != 0 ? byUsd : b.totalKhr.compareTo(a.totalKhr);
    });

    return GiftReportData(
      guestCount: guests.length,
      giftCount: giftSnapshot.docs.length,
      totalUsd: totalUsd,
      totalKhr: totalKhr,
      weddings: [
        for (final entry in weddingTotals.entries)
          WeddingGiftReport(
            weddingId: entry.key,
            weddingName: weddingNames[entry.key] ?? 'Wedding',
            giftCount: entry.value.count,
            totalUsd: entry.value.usd,
            totalKhr: entry.value.khr,
          ),
      ]..sort((a, b) => b.giftCount.compareTo(a.giftCount)),
      byDay: _periodReports(dailyTotals, newestFirst: true),
      byMonth: _periodReports(monthlyTotals, newestFirst: true),
      guests: guestReports,
      largestUsdGift: largestUsdGift,
      largestKhrGift: largestKhrGift,
    );
  }

  List<GiftPeriodReport> _periodReports(
    Map<DateTime, _AmountTotals> totals, {
    required bool newestFirst,
  }) {
    final dates = totals.keys.toList()..sort();
    final orderedDates = newestFirst ? dates.reversed : dates;
    return [
      for (final date in orderedDates)
        GiftPeriodReport(
          period: date,
          giftCount: totals[date]!.count,
          totalUsd: totals[date]!.usd,
          totalKhr: totals[date]!.khr,
        ),
    ];
  }

  String _weddingTitle(Map<String, dynamic> data) {
    final title = (data['weddingTitle'] ?? '').toString().trim();
    if (title.isNotEmpty) return title;
    final couple = [
      (data['groomName'] ?? '').toString().trim(),
      (data['brideName'] ?? '').toString().trim(),
    ].where((name) => name.isNotEmpty).join(' & ');
    return couple.isEmpty ? 'Wedding' : couple;
  }
}

class _AmountTotals {
  int count = 0;
  double usd = 0;
  double khr = 0;

  void add(double amount, String currency) {
    count++;
    if (currency == CurrencyHelper.usd) usd += amount;
    if (currency == CurrencyHelper.khr) khr += amount;
  }
}
