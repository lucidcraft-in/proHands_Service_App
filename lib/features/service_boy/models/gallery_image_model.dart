class GalleryImageModel {
  final String id;
  final String imageUrl;
  final String? description;
  final String? uploadedBy; // ID of uploader
  final DateTime? createdAt;

  GalleryImageModel({
    required this.id,
    required this.imageUrl,
    this.description,
    this.uploadedBy,
    this.createdAt,
  });

  factory GalleryImageModel.fromJson(Map<String, dynamic> json) {
    return GalleryImageModel(
      id: json['_id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'],
      uploadedBy:
          json['uploadedBy'] is Map
              ? json['uploadedBy']['_id']
              : json['uploadedBy'],
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
    );
  }
}
