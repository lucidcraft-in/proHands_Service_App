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
  });

  // factory ServiceProductModel.fromJson(Map<String, dynamic> json) {
  //   String providerName = 'Unknown Provider';
  //   String providerImage = '';
  //   String providerId = '';
  //   double rating = 0.0;
  //   int reviewsCount = 0;
  //   String profession = '';

  //   if (json['providerId'] != null) {
  //     if (json['providerId'] is Map) {
  //       final provider = json['providerId'];
  //       providerName = provider['name'] ?? 'Unknown Provider';
  //       providerId = provider['_id'] ?? '';
  //       rating = (provider['rating'] ?? 0).toDouble();
  //       reviewsCount = provider['reviewsCount'] ?? 0;
  //       profession = provider['profession'] ?? '';
  //       // portfolioImages is a list, take first if available
  //       if (provider['portfolioImages'] != null &&
  //           (provider['portfolioImages'] as List).isNotEmpty) {
  //         providerImage = provider['portfolioImages'][0];
  //       }
  //     } else if (json['providerId'] is String) {
  //       providerId = json['providerId'];
  //     }
  //   }

  //   return ServiceProductModel(
  //     id: json['_id'] ?? '',
  //     name: json['name'] ?? '',
  //     description: json['description'] ?? '',
  //     price: (json['price'] ?? 0).toDouble(),
  //     duration: json['duration'] ?? 0,
  //     providerName: providerName,
  //     providerImage: providerImage,
  //     providerId: providerId,
  //     rating: rating,
  //     reviewsCount: reviewsCount,
  //     profession: profession,
  //     image: json['image'] ?? '',
  //     gallery: List<String>.from(json['gallery'] ?? []),
  //   );
  // }

  factory ServiceProductModel.fromJson(Map<String, dynamic> json) {
    String providerName = 'Service Expert';
    String providerImage = '';
    String providerId = '';
    double rating = 0.0;
    int reviewsCount = 0;
    String profession = '';

    if (json['providerId'] != null) {
      if (json['providerId'] is Map) {
        final provider = json['providerId'];
        providerName = provider['name'] ?? 'Service Expert';
        providerId = provider['_id'] ?? '';
        rating = (provider['rating'] ?? 0).toDouble();
        reviewsCount = provider['reviewsCount'] ?? 0;
        profession = provider['profession'] ?? '';

        if (provider['portfolioImages'] != null &&
            (provider['portfolioImages'] as List).isNotEmpty) {
          providerImage = provider['portfolioImages'][0];
        }
      } else if (json['providerId'] is String) {
        providerId = json['providerId'];
      }
    }

    return ServiceProductModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      duration: json['duration'] ?? 0,
      providerName: providerName,
      providerImage: providerImage,
      providerId: providerId,
      rating: rating,
      reviewsCount: reviewsCount,
      profession: profession,
      image: json['image'] ?? '',
      gallery:
          (json['gallery'] as List? ?? [])
              .map((e) => e['imageUrl'] as String)
              .toList(),
      subcategoryName:
          json['subcategoryId'] != null && json['subcategoryId'] is Map
              ? json['subcategoryId']['name'] ?? ''
              : '',
    );
  }
}
