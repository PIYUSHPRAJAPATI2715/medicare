class ReviewModel {
  final String id;
  final String patientName;
  final double rating;
  final String timeAgo;
  final String comment;
  final bool isVerified;
  final String? conditionTreated;

  const ReviewModel({
    required this.id,
    required this.patientName,
    required this.rating,
    required this.timeAgo,
    required this.comment,
    this.isVerified = true,
    this.conditionTreated,
  });
}
