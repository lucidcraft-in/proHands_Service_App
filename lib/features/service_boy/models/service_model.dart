import '../../home/models/service_product_model.dart';

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int duration;
  final double commission;
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryColor;
  final String categoryImage;
  final String status;
  final bool isActive;
  final bool isTrending;
  final bool isApproved;
  final String? imageUrl;
  final String? providerName;
  final String? providerPhone;
  final String subcategoryId;
  final String subcategoryName;
  final bool isCommissionPending;
  final List<String> additionalSkills;
  final List<SubcategoryModel> subcategories;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.commission,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.categoryImage,
    required this.status,
    required this.isActive,
    required this.isTrending,
    required this.isApproved,
    this.imageUrl,
    this.providerName,
    this.providerPhone,
    this.subcategoryId = '',
    this.subcategoryName = '',
    this.isCommissionPending = false,
    this.additionalSkills = const [],
    this.subcategories = const [],
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    print(json['subcategories']);
    String catId = '';
    String catName = '';
    String catIcon = '';
    String catColor = '';
    String catImage = '';

    if (json['categoryId'] is Map) {
      final cat = json['categoryId'];
      catId = cat['_id'] ?? '';
      catName = cat['name'] ?? '';
      catIcon = cat['icon'] ?? '';
      catColor = cat['color'] ?? '';
      catImage = cat['image'] ?? '';
    } else if (json['categoryId'] is String) {
      catId = json['categoryId'];
    }

    String subCatId = '';
    String subCatName = '';
    if (json['subcategoryId'] is Map) {
      final subCat = json['subcategoryId'];
      subCatId = subCat['_id'] ?? '';
      subCatName = subCat['name'] ?? '';
    } else if (json['subcategoryId'] is String) {
      subCatId = json['subcategoryId'];
    }

    String? providerName;
    String? providerPhone;
    if (json['providerId'] is Map) {
      final provider = json['providerId'];
      providerName = provider['name'];
      providerPhone = provider['phone'];
    }

    return ServiceModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      duration: json['duration'] ?? 0,
      commission: (json['commission'] ?? 0).toDouble(),
      categoryId: catId,
      categoryName: catName,
      categoryIcon: catIcon,
      categoryColor: catColor,
      categoryImage: catImage,
      status: json['status'] ?? 'ACTIVE',
      isActive: json['isActive'] ?? true,
      isTrending: json['isTrending'] ?? false,
      isApproved: json['isApproved'] ?? false,
      imageUrl: json['image'],
      providerName: providerName,
      providerPhone: providerPhone,
      subcategoryId: subCatId,
      subcategoryName: subCatName,
      isCommissionPending: json['isCommissionPending'] ?? false,
      additionalSkills:
          json['additionalSkills'] != null
              ? List<String>.from(json['additionalSkills'])
              : [],
      subcategories:
          json['subcategories'] is List
              ? (json['subcategories'] as List)
                  .map((e) => SubcategoryModel.fromJson(e))
                  .toList()
              : [],
    );
  }
}
