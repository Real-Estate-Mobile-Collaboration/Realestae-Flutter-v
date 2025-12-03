class Review {
  final String id;
  final String propertyId;
  final String userId;
  final String userName;
  final String? userPhoto;
  final int rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    
    return Review(
      id: json['_id'] ?? '',
      propertyId: json['property'] is String 
          ? json['property'] 
          : (json['property'] as Map?)? ['_id'] ?? '',
      userId: user is String 
          ? user 
          : (user as Map?)?['_id'] ?? '',
      userName: user is Map 
          ? (user['name'] as String?) ?? 'Unknown' 
          : 'Unknown',
      userPhoto: user is Map 
          ? user['photo'] as String? 
          : null,
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'property': propertyId,
      'user': userId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
