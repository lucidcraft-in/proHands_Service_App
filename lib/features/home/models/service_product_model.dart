class ServiceProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int duration;
  final String providerName;
  final String providerImage;
  final String providerId;
  final double rating;
  final int reviewsCount;
  final String profession;
  final String image;
  final List<String> gallery;
  final String subcategoryName;
  final String categoryName;
  final String categoryImage;
  final List<String> specialties;
  final List<String> servicesOffered;
  final List<String> additionalSkills;
  final bool isCommissionPending;

  ServiceProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.providerName,
    required this.providerImage,
    required this.providerId,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.profession = '',
    this.image = '',
    this.gallery = const [],
    this.subcategoryName = '',
    this.categoryName = '',
    this.categoryImage = '',
    this.specialties = const [],
    this.servicesOffered = const [],
    this.additionalSkills = const [],
    this.isCommissionPending = false,
  });

  factory ServiceProductModel.fromJson(Map<String, dynamic> json) {
    String providerName = 'Service Expert';
    String providerImage = '';
    String providerId = '';
    double rating = 0.0;
    int reviewsCount = 0;
    String profession = '';
    List<String> specialties = [];
    List<String> servicesOffered = [];
    List<String> additionalSkills = [];

    // Parse provider info
    if (json['providerId'] != null) {
      if (json['providerId'] is Map) {
        final provider = json['providerId'];
        providerName = provider['name'] ?? 'Service Expert';
        providerId = provider['_id'] ?? '';
        rating = (provider['rating'] ?? 0).toDouble();
        reviewsCount = provider['reviewsCount'] ?? 0;
        profession = provider['profession'] ?? '';
        specialties = List<String>.from(provider['specialties'] ?? []);
        servicesOffered = List<String>.from(provider['servicesOffered'] ?? []);
        providerImage = provider['profilePhoto'] ?? '';
        // if (provider['portfolioImages'] != null &&
        //     (provider['portfolioImages'] as List).isNotEmpty) {
        //   providerImage = provider['portfolioImages'][0];
        // }
      } else if (json['providerId'] is String) {
        providerId = json['providerId'];
      }
    }

    // Parse category info
    String catName = '';
    String catImage = '';
    if (json['categoryId'] != null && json['categoryId'] is Map) {
      catName = json['categoryId']['name'] ?? '';
      catImage = json['categoryId']['image'] ?? '';
    }

    // Parse subcategory info
    String subCatName = '';
    if (json['subcategoryId'] != null && json['subcategoryId'] is Map) {
      subCatName = json['subcategoryId']['name'] ?? '';
      // If categoryId was not direct, try to get it from subcategory
      if (catName.isEmpty &&
          json['subcategoryId']['categoryId'] != null &&
          json['subcategoryId']['categoryId'] is Map) {
        catName = json['subcategoryId']['categoryId']['name'] ?? '';
        catImage = json['subcategoryId']['categoryId']['image'] ?? '';
      }
    }

    // Parse images robustly
    String serviceImage = '';
    if (json['image'] != null &&
        json['image'] is String &&
        (json['image'] as String).isNotEmpty) {
      serviceImage = json['image'];
    } else if (json['images'] != null &&
        json['images'] is List &&
        (json['images'] as List).isNotEmpty) {
      serviceImage = json['images'][0];
    } else if (json['image'] != null && json['image'] is Map) {
      serviceImage = (json['image']['imageUrl'] ?? '').toString();
    }

    if (json['additionalSkills'] is List) {
      additionalSkills =
          (json['additionalSkills'] as List).map((e) {
            if (e is Map) {
              return (e['name'] ?? '').toString();
            }
            return e.toString();
          }).toList();
    }

    return ServiceProductModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      duration: (json['duration'] ?? 0).toInt(),
      providerName: providerName,
      providerImage: providerImage,
      providerId: providerId,
      rating: rating,
      reviewsCount: reviewsCount,
      profession: profession,
      image: serviceImage,
      gallery:
          (json['gallery'] as List? ?? []).map((e) {
            if (e is Map) {
              return (e['imageUrl'] ?? '').toString();
            }
            return e.toString();
          }).toList(),
      subcategoryName: subCatName,
      categoryName: catName,
      categoryImage: catImage,
      specialties: specialties,
      servicesOffered: servicesOffered,
      additionalSkills: additionalSkills,
      isCommissionPending: json['isCommissionPending'] ?? false,
    );
  }
}
