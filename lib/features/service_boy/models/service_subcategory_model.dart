class ServiceSubcategoryModel {
  final String id;
  final String name;
  final String categoryId;
  final String icon;
  final bool isActive;

  ServiceSubcategoryModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.icon,
    this.isActive = true,
  });

  factory ServiceSubcategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceSubcategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      categoryId:
          json['categoryId'] is Map
              ? json['categoryId']['_id']
              : (json['categoryId'] ?? ''),
      icon: json['icon'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }
}
