class ParkingSpot {
  final String title;
  final String area;
  final double rating;
  final int reviews;
  final double pricePerHour;
  final String imageUrl;

  const ParkingSpot({
    required this.title,
    required this.area,
    required this.rating,
    required this.reviews,
    required this.pricePerHour,
    required this.imageUrl,
  });
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
