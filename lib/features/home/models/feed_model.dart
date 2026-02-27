import '../../../core/models/user_model.dart';
import '../../../core/models/user_type.dart';

class FeedModel {
  final String id;
  final FeedProvider provider;
  final String title;
  final String description;
  final List<String> images;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  FeedModel({
    required this.id,
    required this.provider,
    required this.title,
    required this.description,
    required this.images,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FeedModel.fromJson(Map<String, dynamic> json) {
    return FeedModel(
      id: json['_id'] ?? '',
      provider: FeedProvider.fromJson(json['provider'] ?? {}),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class FeedProvider {
  final String id;
  final String name;
  final String profession;
  final String serviceImage;
  final double rating;
  final int reviewsCount;
  final List<String> portfolioImages;

  FeedProvider({
    required this.id,
    required this.name,
    required this.profession,
    required this.serviceImage,
    required this.rating,
    required this.reviewsCount,
    required this.portfolioImages,
  });

  factory FeedProvider.fromJson(Map<String, dynamic> json) {
    return FeedProvider(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      profession: json['profession'] ?? 'Service Provider',
      serviceImage: json['serviceImage'] ?? 'https://via.placeholder.com/150',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewsCount: json['reviewsCount'] ?? 0,
      portfolioImages: List<String>.from(json['portfolioImages'] ?? []),
    );
  }

  // Convert to UserModel for compatibility with existing screens
  UserModel toUserModel() {
    return UserModel(
      id: id,
      name: name,
      phone: '', // Not in feed
      userType: UserType.serviceBoy, // Assumed
      profession: profession,
      serviceImage: serviceImage,
      rating: rating,
      reviewsCount: reviewsCount,
      portfolioImages: portfolioImages,
      // Default values for others
    );
  }
}
