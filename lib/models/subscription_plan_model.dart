class SubscriptionPlanModel {
  final String id;
  final String name;
  final String tagline;
  final double price;
  final double originalPrice;
  final int durationDays;
  final String durationLabel;
  final int consultationLimit; // -1 means unlimited
  final List<String> features;
  final bool isPopular;
  final String? badgeText;
  final bool isActive;
  final int colorHex;

  const SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.tagline,
    required this.price,
    required this.originalPrice,
    required this.durationDays,
    required this.durationLabel,
    this.consultationLimit = -1,
    required this.features,
    this.isPopular = false,
    this.badgeText,
    this.isActive = true,
    this.colorHex = 0xFF2B5B84,
  });

  bool get isUnlimited => consultationLimit <= 0;

  int get discountPercentage {
    if (originalPrice <= price || originalPrice == 0) return 0;
    return (((originalPrice - price) / originalPrice) * 100).round();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tagline': tagline,
      'price': price,
      'originalPrice': originalPrice,
      'durationDays': durationDays,
      'durationLabel': durationLabel,
      'consultationLimit': consultationLimit,
      'features': features,
      'isPopular': isPopular,
      'badgeText': badgeText,
      'isActive': isActive,
      'colorHex': colorHex,
    };
  }

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'] as String,
      name: json['name'] as String,
      tagline: json['tagline'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['originalPrice'] as num).toDouble(),
      durationDays: json['durationDays'] as int? ?? 30,
      durationLabel: json['durationLabel'] as String? ?? '1 Month',
      consultationLimit: json['consultationLimit'] as int? ?? -1,
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isPopular: json['isPopular'] as bool? ?? false,
      badgeText: json['badgeText'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      colorHex: json['colorHex'] as int? ?? 0xFF2B5B84,
    );
  }
}
