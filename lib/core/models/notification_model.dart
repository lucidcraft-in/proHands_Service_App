class NotificationModel {
  final String id;
  final String recipient;
  final String type;
  final String title;
  final String message;
  final NotificationData? data;
  final bool isRead;
  final bool isGlobal;
  final String targetGroup;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.recipient,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.isRead,
    required this.isGlobal,
    required this.targetGroup,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      recipient: json['recipient'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      data:
          json['data'] != null ? NotificationData.fromJson(json['data']) : null,
      isRead: json['isRead'] ?? false,
      isGlobal: json['isGlobal'] ?? false,
      targetGroup: json['targetGroup'] ?? 'NONE',
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'recipient': recipient,
      'type': type,
      'title': title,
      'message': message,
      'data': data?.toJson(),
      'isRead': isRead,
      'isGlobal': isGlobal,
      'targetGroup': targetGroup,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class NotificationData {
  final String? bookingId;
  final String? action;
  final String? link;

  NotificationData({this.bookingId, this.action, this.link});

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      bookingId: json['bookingId'],
      action: json['action'],
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'bookingId': bookingId, 'action': action, 'link': link};
  }
}
