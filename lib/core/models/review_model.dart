class ReviewModel {
  final String id;
  final String reviewerPhone;
  final int rating;
  final String comment;
  final List<String> images;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.reviewerPhone,
    required this.rating,
    required this.comment,
    required this.images,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // Handling reviewerId as either a Map with phone or just an ID
    String phone = 'Unknown';
    if (json['reviewerId'] != null && json['reviewerId'] is Map) {
      phone = json['reviewerId']['phone'] ?? 'Unknown';
    }

    return ReviewModel(
      id: json['_id'] ?? '',
      reviewerPhone: phone,
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
    );
  }
}
