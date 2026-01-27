import 'user_type.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserType userType;
  final String otp;
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

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    required this.otp,
    this.profession = 'Technician',
    this.rating = 4.5,
    this.reviewsCount = 42,
    this.bio = 'Professional service provider with years of experience.',
    this.specialties = const ['Service'],
    this.serviceImage = 'assets/images/default_avatar.png',
    this.location = 'Kannur, Kerala',
    this.portfolioImages = const [
      'assets/images/cleaning_service.png',
      'assets/images/painting_service.png',
      'assets/images/ac_repair_service.png',
    ],
    this.postsCount = 6,
    this.followersCount = 2,
  });

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, type: ${userType.displayName})';
  }
}
