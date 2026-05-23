class Restaurant {
  final int id;
  final String name;
  final String city;
  final double? rating;
  final int? priceRange;
  final DateTime? lastReservationDate;
  final int pendingRequestsCount;

  Restaurant({
    required this.id,
    required this.name,
    required this.city,
    this.rating,
    this.priceRange,
    this.lastReservationDate,
    required this.pendingRequestsCount,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as int,
      name: json['name'] as String,
      city: json['city'] as String,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      priceRange: json['price_range'] as int?,
      lastReservationDate: json['last_reservation_date'] != null
          ? DateTime.parse(json['last_reservation_date'])
          : null,
      pendingRequestsCount: json['pending_requests_count'] as int? ?? 0,
    );
  }
}