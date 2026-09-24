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

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: json['id']?.toString() ?? 'h1',
      name: json['name']?.toString() ?? 'Hospital',
      address: json['address']?.toString() ?? 'Jaipur',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 100,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 2.5,
      imageUrl: json['imageUrl']?.toString() ?? 'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=600',
      specialties: (json['facilities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
                   (json['specialties'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
                   ['Emergency Care', 'Pharmacy'],
      timing: json['timing']?.toString() ?? '24/7 Open',
      phone: json['phone']?.toString() ?? '+91 141 275 1871',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'distanceKm': distanceKm,
      'imageUrl': imageUrl,
      'specialties': specialties,
      'timing': timing,
      'phone': phone,
    };
  }
}
