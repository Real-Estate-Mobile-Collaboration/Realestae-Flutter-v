class ListingAnalytics {
  final int totalProperties;
  final int totalViews;
  final int totalBookings;
  final double totalRevenue;

  ListingAnalytics({
    required this.totalProperties,
    required this.totalViews,
    required this.totalBookings,
    required this.totalRevenue,
  });

  factory ListingAnalytics.fromJson(Map<String, dynamic> json) {
    return ListingAnalytics(
      totalProperties: json['totalProperties'],
      totalViews: json['totalViews'],
      totalBookings: json['totalBookings'],
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
    );
  }
}

class PropertyAnalytics {
  final int views;
  final int totalBookings;
  final double totalRevenue;
  final List<BookingAnalytics> bookings;

  PropertyAnalytics({
    required this.views,
    required this.totalBookings,
    required this.totalRevenue,
    required this.bookings,
  });

  factory PropertyAnalytics.fromJson(Map<String, dynamic> json) {
    var bookingList = json['bookings'] as List;
    List<BookingAnalytics> bookings =
        bookingList.map((i) => BookingAnalytics.fromJson(i)).toList();

    return PropertyAnalytics(
      views: json['views'],
      totalBookings: json['totalBookings'],
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      bookings: bookings,
    );
  }
}

class BookingAnalytics {
  final String id;
  final String user;
  final DateTime bookingDate;
  final double totalPrice;

  BookingAnalytics({
    required this.id,
    required this.user,
    required this.bookingDate,
    required this.totalPrice,
  });

  factory BookingAnalytics.fromJson(Map<String, dynamic> json) {
    return BookingAnalytics(
      id: json['_id'],
      user: json['user'],
      bookingDate: DateTime.parse(json['bookingDate']),
      totalPrice: (json['totalPrice'] as num).toDouble(),
    );
  }
}
