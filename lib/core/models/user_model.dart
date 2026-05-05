import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'user_type.dart';

class BankDetails {
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? accountHolderName;

  const BankDetails({
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.accountHolderName,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      bankName: json['bankName'],
      accountNumber: json['accountNumber'],
      ifscCode: json['ifscCode'],
      accountHolderName: json['accountHolderName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankName': bankName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'accountHolderName': accountHolderName,
    };
  }
}

class UserModel {
  final String id;
  final String? name; // Nullable as it might not be in login response
  final String? email; // Nullable
  final String phone;
  final UserType userType;
  final bool isProfileComplete;
  final bool isActive;
  final bool isApproved;
  final String? address;
  final String?
  otp; // Keep if needed, but usually not stored in client model for long
  final String profession;
  final double rating;
  final int reviewsCount;
  final String bio;
  final List<String> specialties;
  final String serviceImage;
  final String profilePhoto;
  final String location;
  final List<String> portfolioImages;
  final int postsCount;
  final int followersCount;
  final List<String> servicesOffered;
  final List<String> workPreference;
  final List<dynamic> workLocationPreferred;
  final String experience;
  final String? adharCard;
  final String? license;
  final double? latitude;
  final double? longitude;
  final bool? isCommissionPending;
  final int jobsCompleted;
  final double earnings;
  final double completionRate;
  final bool isProfilePhotoApproved;
  final String? proofOfIdentity;
  final int points;
  final int totalRedeemedPoints;
  final List<String> additionalDocuments;
  final String? updatedBy;
  final BankDetails? bankDetails;

  const UserModel({
    required this.id,
    this.name,
    this.email,
    required this.phone,
    required this.userType,
    this.isProfileComplete = false,
    this.isActive = true,
    this.otp,
    this.address,
    this.isApproved = false,
    this.profession = 'Technician',
    this.rating = 4.5,
    this.reviewsCount = 42,
    this.bio = 'Professional service provider with years of experience.',
    this.specialties = const ['Service'],
    this.serviceImage = 'assets/images/default_avatar.png',
    this.profilePhoto = 'assets/images/default_avatar.png',
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
    this.latitude,
    this.longitude,
    this.isCommissionPending,
    this.jobsCompleted = 0,
    this.earnings = 0.0,
    this.completionRate = 0.0,
    this.isProfilePhotoApproved = false,
    this.proofOfIdentity,
    this.points = 0,
    this.totalRedeemedPoints = 0,
    this.additionalDocuments = const [],
    this.updatedBy,
    this.bankDetails,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Parse location
    String parsedLocation = json['address'] ?? 'Unknown';
    double? lat;
    double? lng;

    if (json['location'] is Map) {
      final locMap = json['location'] as Map<String, dynamic>;
      parsedLocation =
          locMap['location_name'] ??
          locMap['city'] ??
          json['location_name'] ??
          'Unknown';

      if (locMap['type'] == 'Point' && locMap['coordinates'] is List) {
        final coords = locMap['coordinates'] as List;
        if (coords.length >= 2) {
          // GeoJSON is [longitude, latitude]
          lng = (coords[0] as num).toDouble();
          lat = (coords[1] as num).toDouble();
        }
      } else if (locMap['latitude'] != null && locMap['longitude'] != null) {
        lat = (locMap['latitude'] as num).toDouble();
        lng = (locMap['longitude'] as num).toDouble();
      }
    } else if (json['location'] is String) {
      parsedLocation = json['location'];
    }

    // Final fallback: If we have coordinates but still no address, show "Saved Location" instead of "Unknown"
    if (parsedLocation == 'Unknown' && lat != null && lng != null) {
      parsedLocation = 'Saved Location';
    }

    return UserModel(
      id: json['_id'] ?? '',
      name:
          (json['name'] != null && json['name'].toString().isNotEmpty)
              ? json['name']
              : 'Guest',
      email: json['email'],
      phone: json['phone'] ?? '',
      address: json['address'],
      isApproved: json['isApproved'] ?? false,
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
      profilePhoto: json['profilePhoto'] ?? 'assets/images/default_avatar.png',
      location: parsedLocation,
      portfolioImages: List<String>.from(json['portfolioImages'] ?? []),
      postsCount: json['postsCount'] ?? 0,
      followersCount: json['followersCount'] ?? 0,
      servicesOffered: List<String>.from(json['servicesOffered'] ?? []),
      workPreference: List<String>.from(json['workPreference'] ?? []),
      workLocationPreferred:
          (json['workLocationPreferred'] as List?)?.map((e) {
            if (e is Map) {
              return jsonEncode(e);
            }
            return e.toString();
          }).toList() ??
          [],
      experience: json['experience']?.toString() ?? '0',
      adharCard: json['adharCard'],
      license: json['license'],
      latitude: lat,
      longitude: lng,
      isCommissionPending: json['isCommissionPending'] ?? false,
      jobsCompleted: json['jobsCompleted'] ?? 0,
      earnings: (json['earnings'] ?? 0.0).toDouble(),
      completionRate: (json['completionRate'] ?? 0.0).toDouble(),
      isProfilePhotoApproved: json['isProfilePhotoApproved'] ?? false,
      proofOfIdentity: json['proofOfIdentity'],
      points: json['points'] ?? 0,
      totalRedeemedPoints: json['totalRedeemedPoints'] ?? 0,
      additionalDocuments: List<String>.from(json['additionalDocuments'] ?? []),
      updatedBy: json['updatedBy'],
      bankDetails:
          json['bankDetails'] != null
              ? BankDetails.fromJson(json['bankDetails'])
              : null,
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
      'isApproved': isApproved,
      'specialties': specialties,
      'serviceImage': serviceImage,
      'profilePhoto': profilePhoto,
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
      'latitude': latitude,
      'longitude': longitude,
      'isCommissionPending': isCommissionPending,
      'jobsCompleted': jobsCompleted,
      'earnings': earnings,
      'completionRate': completionRate,
      'isProfilePhotoApproved': isProfilePhotoApproved,
      'proofOfIdentity': proofOfIdentity,
      'points': points,
      'totalRedeemedPoints': totalRedeemedPoints,
      'additionalDocuments': additionalDocuments,
      'updatedBy': updatedBy,
      'bankDetails': bankDetails?.toJson(),
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

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserType? userType,
    bool? isProfileComplete,
    bool? isActive,
    bool? isApproved,
    String? address,
    String? otp,
    String? profession,
    double? rating,
    int? reviewsCount,
    String? bio,
    List<String>? specialties,
    String? serviceImage,
    String? profilePhoto,
    String? location,
    List<String>? portfolioImages,
    int? postsCount,
    int? followersCount,
    List<String>? servicesOffered,
    List<String>? workPreference,
    List<dynamic>? workLocationPreferred,
    String? experience,
    String? adharCard,
    String? license,
    double? latitude,
    double? longitude,
    bool? isCommissionPending,
    int? jobsCompleted,
    double? earnings,
    double? completionRate,
    bool? isProfilePhotoApproved,
    String? proofOfIdentity,
    int? points,
    int? totalRedeemedPoints,
    List<String>? additionalDocuments,
    String? updatedBy,
    BankDetails? bankDetails,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      userType: userType ?? this.userType,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      isActive: isActive ?? this.isActive,
      isApproved: isApproved ?? this.isApproved,
      address: address ?? this.address,
      otp: otp ?? this.otp,
      profession: profession ?? this.profession,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      bio: bio ?? this.bio,
      specialties: specialties ?? this.specialties,
      serviceImage: serviceImage ?? this.serviceImage,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      location: location ?? this.location,
      portfolioImages: portfolioImages ?? this.portfolioImages,
      postsCount: postsCount ?? this.postsCount,
      followersCount: followersCount ?? this.followersCount,
      servicesOffered: servicesOffered ?? this.servicesOffered,
      workPreference: workPreference ?? this.workPreference,
      workLocationPreferred:
          workLocationPreferred ?? this.workLocationPreferred,
      experience: experience ?? this.experience,
      adharCard: adharCard ?? this.adharCard,
      license: license ?? this.license,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isCommissionPending: isCommissionPending ?? this.isCommissionPending,
      jobsCompleted: jobsCompleted ?? this.jobsCompleted,
      earnings: earnings ?? this.earnings,
      completionRate: completionRate ?? this.completionRate,
      isProfilePhotoApproved:
          isProfilePhotoApproved ?? this.isProfilePhotoApproved,
      proofOfIdentity: proofOfIdentity ?? this.proofOfIdentity,
      points: points ?? this.points,
      totalRedeemedPoints: totalRedeemedPoints ?? this.totalRedeemedPoints,
      additionalDocuments: additionalDocuments ?? this.additionalDocuments,
      updatedBy: updatedBy ?? this.updatedBy,
      bankDetails: bankDetails ?? this.bankDetails,
    );
  }
}
