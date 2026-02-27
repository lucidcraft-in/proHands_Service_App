import 'package:flutter/foundation.dart';
import 'user_type.dart';

class UserModel {
  final String id;
  final String? name; // Nullable as it might not be in login response
  final String? email; // Nullable
  final String phone;
  final UserType userType;
  final bool isProfileComplete;
  final bool isActive;
  final String?
  otp; // Keep if needed, but usually not stored in client model for long
  final String profession;
  final double rating;
  final int reviewsCount;
  final String bio;
  final List<String> specialties;
  final String serviceImage;
  final String location;
  final List<String> portfolioImages;
  final int postsCount;
  final int followersCount;
  final List<String> servicesOffered;
  final List<String> workPreference;
  final List<String> workLocationPreferred;
  final String experience;
  final String? adharCard;
  final String? license;

  const UserModel({
    required this.id,
    this.name,
    this.email,
    required this.phone,
    required this.userType,
    this.isProfileComplete = false,
    this.isActive = true,
    this.otp,
    this.profession = 'Technician',
    this.rating = 4.5,
    this.reviewsCount = 42,
    this.bio = 'Professional service provider with years of experience.',
    this.specialties = const ['Service'],
    this.serviceImage = 'assets/images/default_avatar.png',
    this.location = 'Unknown',
    this.portfolioImages = const [],
    this.postsCount = 0,
    this.followersCount = 0,
    this.servicesOffered = const [],
    this.workPreference = const [],
    this.workLocationPreferred = const [],
    this.experience = '0',
    this.adharCard,
    this.license,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Parse location
    String parsedLocation = 'Unknown';
    if (json['location'] is Map) {
      parsedLocation = json['location']['address'] ?? 'Unknown';
    } else if (json['location'] is String) {
      parsedLocation = json['location'];
    }

    return UserModel(
      id: json['_id'] ?? '',
      name:
          (json['name'] != null && json['name'].toString().isNotEmpty)
              ? json['name']
              : 'Guest',
      email: json['email'],
      phone: json['phone'] ?? '',
      userType: _parseUserType(json['userType']),
      isProfileComplete: json['isProfileComplete'] ?? false,
      isActive: json['isActive'] ?? true,
      otp: json['otp'],
      profession: json['profession'] ?? 'Technician',
      rating: (json['rating'] ?? 4.5).toDouble(),
      reviewsCount: json['reviewsCount'] ?? 0,
      bio:
          json['bio'] ??
          'Professional service provider with years of experience.',
      specialties: List<String>.from(json['specialties'] ?? ['Service']),
      serviceImage: json['serviceImage'] ?? 'assets/images/default_avatar.png',
      location: parsedLocation,
      portfolioImages: List<String>.from(json['portfolioImages'] ?? []),
      postsCount: json['postsCount'] ?? 0,
      followersCount: json['followersCount'] ?? 0,
      servicesOffered: List<String>.from(json['servicesOffered'] ?? []),
      workPreference: List<String>.from(json['workPreference'] ?? []),
      workLocationPreferred: List<String>.from(
        json['workLocationPreferred'] ?? [],
      ),
      experience: json['experience']?.toString() ?? '0',
      adharCard: json['adharCard'],
      license: json['license'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name ?? 'Guest',
      'email': email,
      'phone': phone,
      'userType': userType.name,
      'isProfileComplete': isProfileComplete,
      'isActive': isActive,
      'otp': otp,
      'profession': profession,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'bio': bio,
      'specialties': specialties,
      'serviceImage': serviceImage,
      'location': location,
      'portfolioImages': portfolioImages,
      'postsCount': postsCount,
      'followersCount': followersCount,
      'servicesOffered': servicesOffered,
      'workPreference': workPreference,
      'workLocationPreferred': workLocationPreferred,
      'experience': experience,
      'adharCard': adharCard,
      'license': license,
    };
  }

  static UserType _parseUserType(String? type) {
    debugPrint('Parsing UserType: \'$type\'');
    if (type == null) return UserType.customer;

    final normalizedType = type.trim().toUpperCase();
    debugPrint('Normalized UserType: \'$normalizedType\'');

    if (normalizedType == 'SERVICE_BOY' || normalizedType == 'SERVICEBOY') {
      return UserType.serviceBoy;
    }

    if (normalizedType == 'CUSTOMER') {
      return UserType.customer;
    }

    try {
      return UserType.values.firstWhere(
        (e) => e.name.toUpperCase() == normalizedType,
      );
    } catch (_) {
      debugPrint('Unknown UserType: $type, defaulting to customer');
      return UserType.customer;
    }
  }

  @override
  String toString() {
    return 'UserModel(id: $id, phone: $phone, type: ${userType.displayName}, complete: $isProfileComplete)';
  }
}
