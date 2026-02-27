class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int duration;
  final String categoryId;
  final String categoryName; // Extracted from nested category object
  final String categoryIcon; // Extracted from nested category object
  final String status;
  final bool isActive;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.status,
    required this.isActive,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    String catId = '';
    String catName = '';
    String catIcon = '';

    if (json['categoryId'] is Map) {
      final cat = json['categoryId'];
      catId = cat['_id'] ?? '';
      catName = cat['name'] ?? '';
      catIcon = cat['icon'] ?? '';
    } else if (json['categoryId'] is String) {
      catId = json['categoryId'];
    }

    return ServiceModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      duration: json['duration'] ?? 0,
      categoryId: catId,
      categoryName: catName,
      categoryIcon: catIcon,
      status: json['status'] ?? 'ACTIVE',
      isActive: json['isActive'] ?? true,
    );
  }
}
