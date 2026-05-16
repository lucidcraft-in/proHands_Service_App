class PointLogModel {
  final String id;
  final String userId;
  final int points;
  final String type; // 'CREDIT' or 'DEBIT'
  final String reason;
  final String createdAt;
  final String updatedAt;

  PointLogModel({
    required this.id,
    required this.userId,
    required this.points,
    required this.type,
    required this.reason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PointLogModel.fromJson(Map<String, dynamic> json) {
    return PointLogModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      points: json['points'] ?? 0,
      type: json['type'] ?? 'CREDIT',
      reason: json['reason'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}
