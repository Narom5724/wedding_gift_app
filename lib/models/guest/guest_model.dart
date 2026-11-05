import 'package:cloud_firestore/cloud_firestore.dart';

class GuestModel {
  final String id;
  final String userId;
  final String weddingId;
  final String fullName;
  final String gender;
  final String phone;
  final String address;
  final String relationship;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  GuestModel({
    required this.id,
    required this.userId,
    required this.weddingId,
    required this.fullName,
    this.gender = '',
    required this.phone,
    this.address = '',
    required this.relationship,
    this.notes = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  String get ownerId => userId;

  factory GuestModel.fromMap(Map<String, dynamic> map, {String? id}) {
    final created =
        (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final updated = (map['updatedAt'] as Timestamp?)?.toDate() ?? created;

    return GuestModel(
      id: id ?? (map['id'] ?? '').toString(),
      userId: (map['userId'] ?? '').toString(),
      weddingId: (map['weddingId'] ?? '').toString(),
      fullName: (map['fullName'] ?? '').toString(),
      gender: (map['gender'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      address: (map['address'] ?? '').toString(),
      relationship: (map['relationship'] ?? '').toString(),
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
      'fullName': fullName,
      'gender': gender,
      'phone': phone,
      'address': address,
      'relationship': relationship,
      'notes': notes,
      if (forCreate) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  GuestModel copyWith({
    String? id,
    String? userId,
    String? weddingId,
    String? fullName,
    String? gender,
    String? phone,
    String? address,
    String? relationship,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GuestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      weddingId: weddingId ?? this.weddingId,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      relationship: relationship ?? this.relationship,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
