class ReviewModel {
  final String id;
  final String reviewerPhone;
  final String reviewerName;
  final String displayBookingId;
  final String serviceName;
  final int rating;
  final String comment;
  final List<String> images;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.reviewerPhone,
    required this.reviewerName,
    required this.displayBookingId,
    required this.serviceName,
    required this.rating,
    required this.comment,
    required this.images,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // Handling reviewerId as either a Map with phone or just an ID
    String phone = 'Unknown';
    String name = 'Unknown Customer';
    if (json['reviewerId'] != null && json['reviewerId'] is Map) {
      phone = json['reviewerId']['phone'] ?? 'Unknown';
      name = json['reviewerId']['name'] ?? 'Unknown Customer';
    }

    String bookingIdStr = '';
    String serviceNameStr = '';
    if (json['bookingId'] != null && json['bookingId'] is Map) {
      bookingIdStr = json['bookingId']['bookingId'] ?? '';
      if (json['bookingId']['serviceId'] != null &&
          json['bookingId']['serviceId'] is Map) {
        serviceNameStr = json['bookingId']['serviceId']['name'] ?? '';
      }
    }

    return ReviewModel(
      id: json['_id'] ?? '',
      reviewerPhone: phone,
      reviewerName: name,
      displayBookingId: bookingIdStr,
      serviceName: serviceNameStr,
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
