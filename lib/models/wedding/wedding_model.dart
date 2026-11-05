import 'package:cloud_firestore/cloud_firestore.dart';

class WeddingModel {
  final String id;
  final String userId;
  final String weddingTitle;
  final String groomName;
  final String brideName;
  final DateTime weddingDate;
  final String weddingTime;
  final String weddingLocation;
  final String contactPhone;
  final String description;
  final String coverImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  WeddingModel({
    required this.id,
    required this.userId,
    required this.weddingTitle,
    required this.groomName,
    required this.brideName,
    required this.weddingDate,
    this.weddingTime = '',
    this.weddingLocation = '',
    this.contactPhone = '',
    this.description = '',
    this.coverImageUrl = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  String get ownerId => userId;
  String get location => weddingLocation;
  String get notes => description;
  String get imagePath => coverImageUrl;
  String get title =>
      weddingTitle.isNotEmpty ? weddingTitle : '$groomName & $brideName';

  factory WeddingModel.fromMap(Map<String, dynamic> map, {String? id}) {
    final now = DateTime.now();
    final created = _dateTimeFrom(map['createdAt']) ?? now;
    final updated = _dateTimeFrom(map['updatedAt']) ?? created;

    return WeddingModel(
      id: id ?? (map['id'] ?? '').toString(),
      userId: (map['userId'] ?? '').toString(),
      weddingTitle: (map['weddingTitle'] ?? '').toString(),
      groomName: (map['groomName'] ?? '').toString(),
      brideName: (map['brideName'] ?? '').toString(),
      weddingDate: _dateTimeFrom(map['weddingDate']) ?? now,
      weddingTime: (map['weddingTime'] ?? '').toString(),
      weddingLocation: (map['weddingLocation'] ?? map['location'] ?? '')
          .toString(),
      contactPhone: (map['contactPhone'] ?? '').toString(),
      description: (map['description'] ?? map['notes'] ?? '').toString(),
      coverImageUrl: (map['coverImageUrl'] ?? map['imagePath'] ?? '')
          .toString(),
      createdAt: created,
      updatedAt: updated,
    );
  }

  static DateTime? _dateTimeFrom(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Map<String, dynamic> toMap({bool forCreate = false}) {
    return {
      'id': id,
      'userId': userId,
      'weddingTitle': weddingTitle,
      'groomName': groomName,
      'brideName': brideName,
      'weddingDate': Timestamp.fromDate(weddingDate),
      'weddingTime': weddingTime,
      'weddingLocation': weddingLocation,
      'contactPhone': contactPhone,
      'description': description,
      'coverImageUrl': coverImageUrl,
      if (forCreate) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  WeddingModel copyWith({
    String? id,
    String? userId,
    String? weddingTitle,
    String? groomName,
    String? brideName,
    DateTime? weddingDate,
    String? weddingTime,
    String? weddingLocation,
    String? contactPhone,
    String? description,
    String? coverImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeddingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      weddingTitle: weddingTitle ?? this.weddingTitle,
      groomName: groomName ?? this.groomName,
      brideName: brideName ?? this.brideName,
      weddingDate: weddingDate ?? this.weddingDate,
      weddingTime: weddingTime ?? this.weddingTime,
      weddingLocation: weddingLocation ?? this.weddingLocation,
      contactPhone: contactPhone ?? this.contactPhone,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
