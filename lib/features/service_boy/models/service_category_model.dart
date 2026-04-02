class ServiceCategoryModel {
  final String id;
  final String name;
  final String icon;
  final String color;
  final String image;

  ServiceCategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.image,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      color: json['color'] ?? 'white',
      image: json['image'] ?? '',
    );
  }
}
