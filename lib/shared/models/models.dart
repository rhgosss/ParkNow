class ParkingSpot {
  final String id;
  final String title;
  final String area;
  final double rating;
  final int reviews;
  final double pricePerHour;
  final String imageUrl;
  final double latitude;
  final double longitude;

  const ParkingSpot({
    required this.id,
    required this.title,
    required this.area,
    required this.rating,
    required this.reviews,
    required this.pricePerHour,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'area': area,
      'rating': rating,
      'reviews': reviews,
      'price_per_hour': pricePerHour,
      'image_url': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory ParkingSpot.fromMap(Map<String, dynamic> map) {
    return ParkingSpot(
      id: map['id'],
      title: map['title'],
      area: map['area'],
      rating: map['rating'],
      reviews: map['reviews'],
      pricePerHour: map['price_per_hour'],
      imageUrl: map['image_url'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}

class BookingItem {
  final String title;
  final String area;
  final String date;
  final String time;
  final double total;
  final String status;

  const BookingItem({
    required this.title,
    required this.area,
    required this.date,
    required this.time,
    required this.total,
    required this.status,
  });
}
