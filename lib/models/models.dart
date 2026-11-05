enum GiftCurrency { usd, khr }

extension GiftCurrencyX on GiftCurrency {
  String get label {
    switch (this) {
      case GiftCurrency.usd:
        return 'USD';
      case GiftCurrency.khr:
        return 'KHR';
    }
  }

  String get symbol {
    switch (this) {
      case GiftCurrency.usd:
        return '\$';
      case GiftCurrency.khr:
        return '៛';
    }
  }

  static GiftCurrency fromString(String value) {
    switch (value.toUpperCase()) {
      case 'USD':
        return GiftCurrency.usd;
      case 'KHR':
        return GiftCurrency.khr;
      default:
        return GiftCurrency.usd;
    }
  }
}

class Wedding {
  Wedding({
    required this.id,
    required this.ownerId,
    required this.groomName,
    required this.brideName,
    required this.weddingDate,
    required this.location,
    required this.contactPhone,
    this.imagePath,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String groomName;
  final String brideName;
  final DateTime weddingDate;
  final String location;
  final String contactPhone;
  final String? imagePath;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get title => '$groomName & $brideName';

  Wedding copyWith({
    String? id,
    String? ownerId,
    String? groomName,
    String? brideName,
    DateTime? weddingDate,
    String? location,
    String? contactPhone,
    String? imagePath,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Wedding(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      groomName: groomName ?? this.groomName,
      brideName: brideName ?? this.brideName,
      weddingDate: weddingDate ?? this.weddingDate,
      location: location ?? this.location,
      contactPhone: contactPhone ?? this.contactPhone,
      imagePath: imagePath ?? this.imagePath,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Guest {
  Guest({
    required this.id,
    required this.ownerId,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.relationship,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String fullName;
  final String phone;
  final String address;
  final String relationship;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class Gift {
  Gift({
    required this.id,
    required this.ownerId,
    required this.weddingId,
    required this.guestId,
    required this.amountMinor,
    required this.currency,
    required this.giftDate,
    required this.receivedBy,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String weddingId;
  final String guestId;
  final int amountMinor;
  final GiftCurrency currency;
  final DateTime giftDate;
  final String receivedBy;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isValid => amountMinor > 0;

  String formattedAmount({bool showCode = true}) {
    final number = currency == GiftCurrency.usd
        ? amountMinor / 100
        : amountMinor.toDouble();
    final value = number.toStringAsFixed(currency == GiftCurrency.usd ? 2 : 0);
    return showCode ? '${currency.symbol} $value' : value;
  }
}

class UserProfile {
  UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    this.phone = '',
    required this.createdAt,
    required this.updatedAt,
  });

  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final DateTime createdAt;
  final DateTime updatedAt;
}
