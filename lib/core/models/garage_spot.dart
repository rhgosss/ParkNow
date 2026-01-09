class GarageSpot {
  final String id;
  final String title;
  final String address;
  final double lat;
  final double lng;
  final double pricePerHour;
  final double rating;
  final int reviews;
  final bool covered;
  final bool guard247;
  final bool cameras;

  const GarageSpot({
    required this.id,
    required this.title,
    required this.address,
    required this.lat,
    required this.lng,
    required this.pricePerHour,
    required this.rating,
    required this.reviews,
    required this.covered,
    required this.guard247,
    required this.cameras,
  });
}
