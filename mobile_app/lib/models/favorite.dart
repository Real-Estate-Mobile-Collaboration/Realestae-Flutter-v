import 'property.dart';

class Favorite {
  final String id;
  final String userId;
  final Property property;
  final DateTime createdAt;

  Favorite({
    required this.id,
    required this.userId,
    required this.property,
    required this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['user'] ?? '',
      property: Property.fromJson(json['property']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId,
      'property': property.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
