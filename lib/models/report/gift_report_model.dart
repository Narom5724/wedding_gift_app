class GiftReportData {
  const GiftReportData({
    this.guestCount = 0,
    this.giftCount = 0,
    this.totalUsd = 0,
    this.totalKhr = 0,
    this.weddings = const [],
    this.byDay = const [],
    this.byMonth = const [],
    this.guests = const [],
    this.largestUsdGift,
    this.largestKhrGift,
  });

  final int guestCount;
  final int giftCount;
  final double totalUsd;
  final double totalKhr;
  final List<WeddingGiftReport> weddings;
  final List<GiftPeriodReport> byDay;
  final List<GiftPeriodReport> byMonth;
  final List<GuestGiftReport> guests;
  final LargestGiftReport? largestUsdGift;
  final LargestGiftReport? largestKhrGift;
}

class WeddingGiftReport {
  const WeddingGiftReport({
    required this.weddingId,
    required this.weddingName,
    required this.giftCount,
    required this.totalUsd,
    required this.totalKhr,
  });

  final String weddingId;
  final String weddingName;
  final int giftCount;
  final double totalUsd;
  final double totalKhr;
}

class GiftPeriodReport {
  const GiftPeriodReport({
    required this.period,
    required this.giftCount,
    required this.totalUsd,
    required this.totalKhr,
  });

  final DateTime period;
  final int giftCount;
  final double totalUsd;
  final double totalKhr;
}

class GuestGiftReport {
  const GuestGiftReport({
    required this.guestName,
    required this.relationship,
    required this.phone,
    required this.weddingName,
    required this.giftCount,
    required this.totalUsd,
    required this.totalKhr,
  });

  final String guestName;
  final String relationship;
  final String phone;
  final String weddingName;
  final int giftCount;
  final double totalUsd;
  final double totalKhr;
}

class LargestGiftReport {
  const LargestGiftReport({
    required this.guestName,
    required this.weddingName,
    required this.amount,
    required this.currency,
    required this.date,
  });

  final String guestName;
  final String weddingName;
  final double amount;
  final String currency;
  final DateTime date;
}
