class BannerModel {
  final String id;
  final String imageUrl;
  final String title;
  final String description;
  final String linkType;
  final String linkId;
  final String targetUserType;
  final String location;
  final int position;
  final bool isActive;

  BannerModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.linkType,
    required this.linkId,
    required this.targetUserType,
    required this.location,
    required this.position,
    required this.isActive,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['_id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      linkType: json['linkType'] ?? '',
      linkId: json['linkId'] ?? '',
      targetUserType: json['targetUserType'] ?? 'ALL',
      location: json['location'] ?? '',
      position: json['position'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'imageUrl': imageUrl,
      'title': title,
      'description': description,
      'linkType': linkType,
      'linkId': linkId,
      'targetUserType': targetUserType,
      'location': location,
      'position': position,
      'isActive': isActive,
    };
  }
}
