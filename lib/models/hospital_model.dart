class HospitalModel {
  final String id;
  final String name;
  final String address;
  final double rating;
  final int reviewsCount;
  final double distanceKm;
  final String imageUrl;
  final List<String> specialties;
  final String timing;
  final String phone;

  const HospitalModel({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.reviewsCount,
    required this.distanceKm,
    required this.imageUrl,
    required this.specialties,
    required this.timing,
    required this.phone,
  });
}
