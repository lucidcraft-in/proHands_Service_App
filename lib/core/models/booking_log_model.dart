class BookingLogModel {
  final String id;
  final String bookingId;
  final String notes;
  final String createdAt;
  final String createdByName;
  final String createdByUserType;

  BookingLogModel({
    required this.id,
    required this.bookingId,
    required this.notes,
    required this.createdAt,
    required this.createdByName,
    required this.createdByUserType,
  });

  factory BookingLogModel.fromJson(Map<String, dynamic> json) {
    final createdBy = json['createdBy'] as Map<String, dynamic>? ?? {};

    return BookingLogModel(
      id: json['_id'] ?? '',
      bookingId: json['bookingId'] ?? '',
      notes: json['notes'] ?? '',
      createdAt: json['createdAt'] ?? '',
      createdByName: createdBy['name'] ?? 'Unknown',
      createdByUserType: createdBy['userType'] ?? 'SYSTEM',
    );
  }
}
