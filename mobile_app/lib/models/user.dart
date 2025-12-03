class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? photo;
  final String? address;
  final String? bio;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final Map<String, dynamic>? notifications;
  final String? language;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photo,
    this.address,
    this.bio,
    this.role = 'user',
    this.isActive = true,
    required this.createdAt,
    this.notifications,
    this.language,
  });

  // Helper method to get full photo URL
  String? get photoUrl {
    if (photo == null || photo!.isEmpty) return null;
    
    // If it's already a full URL, return it
    if (photo!.startsWith('http://') || photo!.startsWith('https://')) {
      return photo;
    }
    
    // If it's a default avatar that doesn't exist, return null
    if (photo == 'default-avatar.png' || photo == 'avatar.png') {
      return null;
    }
    
    // Otherwise, construct the full URL with cache buster
    // For web: http://localhost:5000/uploads/filename?t=timestamp
    // For mobile: http://YOUR_IP:5000/uploads/filename?t=timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    const bool kIsWeb = identical(0, 0.0);
    if (kIsWeb) {
      return 'http://localhost:5000/uploads/$photo?t=$timestamp';
    } else {
      // Change this IP to match your computer's IP for mobile testing
      return 'http://192.168.1.6:5000/uploads/$photo?t=$timestamp';
    }
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      photo: json['photo'],
      address: json['address'],
      bio: json['bio'],
      role: json['role'] ?? 'user',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      notifications: json['notifications'],
      language: json['language'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photo': photo,
      'address': address,
      'bio': bio,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'notifications': notifications,
      'language': language,
    };
  }
}
