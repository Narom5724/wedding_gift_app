import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/currency_helper.dart';

class GiftModel {
  final String id;
  final String userId;
  final String weddingId;
  final String guestId;
  final double amount;
  final String currency;
  final DateTime receivedDate;
  final String paymentMethod;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  GiftModel({
    required this.id,
    required this.userId,
    required this.weddingId,
    required this.guestId,
    required this.amount,
    required this.currency,
    required this.receivedDate,
    this.paymentMethod = 'Cash',
    this.notes = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  String get ownerId => userId;
  DateTime get giftDate => receivedDate;
  String get receivedBy => paymentMethod;

  bool matchesSearch(String query, {Iterable<String> relatedNames = const []}) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;

    final searchableValues = [
      id,
      weddingId,
      guestId,
      amount.toString(),
      currency,
      receivedDate.toIso8601String(),
      paymentMethod,
      notes,
      ...relatedNames,
    ];
    return searchableValues.any(
      (value) => value.toLowerCase().contains(normalizedQuery),
    );
  }

  factory GiftModel.fromMap(Map<String, dynamic> map, {String? id}) {
    final created =
        (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final updated = (map['updatedAt'] as Timestamp?)?.toDate() ?? created;
    final received =
        (map['receivedDate'] as Timestamp?)?.toDate() ?? DateTime.now();

    return GiftModel(
      id: id ?? (map['id'] ?? '').toString(),
      userId: (map['userId'] ?? '').toString(),
      weddingId: (map['weddingId'] ?? '').toString(),
      guestId: (map['guestId'] ?? '').toString(),
      amount: (map['amount'] is num ? (map['amount'] as num).toDouble() : 0.0),
      currency: CurrencyHelper.normalize((map['currency'] ?? 'USD').toString()),
      receivedDate: received,
      paymentMethod: (map['paymentMethod'] ?? 'Cash').toString(),
      notes: (map['notes'] ?? '').toString(),
      createdAt: created,
      updatedAt: updated,
    );
  }

  Map<String, dynamic> toMap({bool forCreate = false}) {
    return {
      'id': id,
      'userId': userId,
      'weddingId': weddingId,
      'guestId': guestId,
      'amount': amount,
      'currency': currency,
      'receivedDate': Timestamp.fromDate(receivedDate),
      'paymentMethod': paymentMethod,
      'notes': notes,
      if (forCreate) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  GiftModel copyWith({
    String? id,
    String? userId,
    String? weddingId,
    String? guestId,
    double? amount,
    String? currency,
    DateTime? receivedDate,
    String? paymentMethod,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GiftModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      weddingId: weddingId ?? this.weddingId,
      guestId: guestId ?? this.guestId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      receivedDate: receivedDate ?? this.receivedDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
