import 'user.dart';

class Property {
  final String id;
  final String title;
  final String description;
  final double price;
  final String propertyType;
  final String status;
  final double area;
  final int bedrooms;
  final int bathrooms;
  final PropertyLocation location;
  final List<String> images;
  final List<String> amenities;
  final User? owner;
  final bool isAvailable;
  final int views;
  final bool featured;
  final double averageRating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.propertyType,
    required this.status,
    required this.area,
    this.bedrooms = 0,
    this.bathrooms = 0,
    required this.location,
    this.images = const [],
    this.amenities = const [],
    this.owner,
    this.isAvailable = true,
    this.views = 0,
    this.featured = false,
    this.averageRating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      propertyType: json['propertyType'] ?? '',
      status: json['status'] ?? '',
      area: (json['area'] ?? 0).toDouble(),
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      location: PropertyLocation.fromJson(json['location'] ?? {}),
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : [],
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'])
          : [],
      owner: json['owner'] != null ? User.fromJson(json['owner']) : null,
      isAvailable: json['isAvailable'] ?? true,
      views: json['views'] ?? 0,
      featured: json['featured'] ?? false,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'price': price,
      'propertyType': propertyType,
      'status': status,
      'area': area,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'location': location.toJson(),
      'images': images,
      'amenities': amenities,
      'owner': owner?.toJson(),
      'isAvailable': isAvailable,
      'views': views,
      'featured': featured,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class PropertyLocation {
  final String address;
  final String city;
  final String? state;
  final String country;
  final String? zipCode;
  final Coordinates coordinates;

  PropertyLocation({
    required this.address,
    required this.city,
    this.state,
    this.country = 'Morocco',
    this.zipCode,
    required this.coordinates,
  });

  factory PropertyLocation.fromJson(Map<String, dynamic> json) {
    return PropertyLocation(
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'],
      country: json['country'] ?? 'Morocco',
      zipCode: json['zipCode'],
      coordinates: Coordinates.fromJson(json['coordinates'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'zipCode': zipCode,
      'coordinates': coordinates.toJson(),
    };
  }
}

class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({
    required this.latitude,
    required this.longitude,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
