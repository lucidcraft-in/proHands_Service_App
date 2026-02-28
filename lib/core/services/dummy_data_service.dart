import '../models/user_model.dart';
import '../models/user_type.dart';
import '../models/booking_model.dart';

class DummyDataService {
  // Singleton pattern
  DummyDataService._();
  static final DummyDataService instance = DummyDataService._();

  // Dummy Bookings
  static final List<BookingModel> _dummyBookings = [
    BookingModel(
      id: '1',
      bookingId: '#58961',
      serviceId: 'dummy_service_1',
      serviceName: 'Curtain cleaning',
      date: '24 Feb, 2024',
      time: '10:00 AM',
      location: '123 Street Name, California, USA',
      customerName: 'Vaishnavi',
      customerPhone: '7510538712',
      price: 1200,
      description: 'Deep cleaning of 2BHK',
      status: BookingStatus.assigned,
    ),
    BookingModel(
      id: '2',
      bookingId: '#25636',
      serviceId: 'dummy_service_2',
      serviceName: 'House hold cook',
      date: '25 Feb, 2024',
      time: '11:00 AM',
      location: '456 Oak Avenue, California, USA',
      customerName: 'Rahul',
      customerPhone: '9876543210',
      price: 800,
      description: 'AC not cooling',
      status: BookingStatus.assigned,
    ),
    BookingModel(
      id: '3',
      bookingId: '#12548',
      serviceId: 'dummy_service_3',
      serviceName: 'Garden cleaning',
      date: '26 Feb, 2024',
      time: '09:00 AM',
      location: '789 Pine Street, California, USA',
      customerName: 'Anjali',
      customerPhone: '9988776655',
      price: 500,
      description: 'Tap leakage',
      status: BookingStatus.reached,
    ),
  ];

  List<BookingModel> getBookingsByStatus(BookingStatus status) {
    return _dummyBookings.where((b) => b.status == status).toList();
  }

  void updateBookingStatus(String id, BookingStatus status) {
    final index = _dummyBookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      _dummyBookings[index].status = status;
    }
  }

  void updateBookingAction(
    String id, {
    bool? isCompleteClicked,
    bool? isOTPRequested,
    bool? isVerified,
  }) {
    final index = _dummyBookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      if (isCompleteClicked != null)
        _dummyBookings[index].isCompleteClicked = isCompleteClicked;
      if (isOTPRequested != null)
        _dummyBookings[index].isOTPRequested = isOTPRequested;
      if (isVerified != null) _dummyBookings[index].isVerified = isVerified;
    }
  }

  // Dummy Users (Customers)
  static final List<UserModel> _dummyUsers = [
    const UserModel(
      id: 'user_1',
      name: 'Amal',
      email: 'amal@gmail.com',
      phone: '+91 9876543210',
      userType: UserType.serviceBoy,
      otp: '123456',
      profession: 'Cleaning Expert',
      rating: 4.8,
      reviewsCount: 156,
      bio:
          'Professional cleaner with over 5 years of experience in residential and commercial deep cleaning.',
      specialties: ['Cleaning', 'Ac Repair'],
      serviceImage: 'assets/images/cleaning_service.png',
      location: 'kim, santaAna, Surat',
    ),
    const UserModel(
      id: 'user_2',
      name: 'Abi',
      email: 'abi@gmail.com',
      phone: '+91 1234567890',
      userType: UserType.customer,
      otp: '123456',
    ),
    const UserModel(
      id: 'user_3',
      name: 'Siyed',
      email: 'siyed@gmail.com',
      phone: '+91 9876543210',
      userType: UserType.serviceBoy,
      otp: '123456',
      profession: 'Master Carpenter',
      rating: 4.9,
      reviewsCount: 89,
      bio:
          'Expert carpenter specializing in custom furniture and home repairs.',
      specialties: ['Carpenter', 'Repair'],
      serviceImage: 'assets/images/smart_home_install.png',
      location: 'kim, allentown, Surat',
    ),
    const UserModel(
      id: 'user_4',
      name: 'Amjad',
      email: 'amjad123@gmail.com',
      phone: '+91 1234567890',
      userType: UserType.customer,
      otp: '123456',
    ),
    const UserModel(
      id: 'user_5',
      name: 'Rahul',
      email: 'rahul@gmail.com',
      phone: '+91 9876543210',
      userType: UserType.serviceBoy,
      otp: '123456',
      profession: 'Certified Electrician',
      rating: 4.7,
      reviewsCount: 124,
      bio:
          'Licensed electrician for all your home wiring and appliance repair needs.',
      specialties: ['Electrician', 'Ac Repair'],
      serviceImage: 'assets/images/electrician.png',
      location: 'kim, mesaNew, Surat',
    ),
    const UserModel(
      id: 'user_6',
      name: 'John Doe',
      email: 'john@gmail.com',
      phone: '+91 12345567890',
      userType: UserType.customer,
      otp: '123456',
      profession: 'Professional Plumber',
      rating: 4.6,
      reviewsCount: 78,
      bio:
          'Expert plumber with a focus on quick and reliable leak repairs and installations.',
      specialties: ['Plumber', 'Repair'],
      serviceImage: 'assets/images/plumber.png',
      location: 'Downtown, New Jersey',
    ),
    const UserModel(
      id: 'user_7',
      name: 'Sarah Jenkins',
      email: 'sarah@gmail.com',
      phone: '+91 9876543210',
      userType: UserType.serviceBoy,
      otp: '123456',
      profession: 'Salon & Beauty Expert',
      rating: 4.9,
      reviewsCount: 230,
      bio:
          'Certified beautician providing salon services at the comfort of your home.',
      specialties: ['Salon', 'Cleaning'],
      serviceImage: 'assets/images/saloon.png',
      location: 'Uptown, California',
    ),
    const UserModel(
      id: 'user_8',
      name: 'David Wilson',
      email: 'david@gmail.com',
      phone: '+91 9876543210',
      userType: UserType.customer,
      otp: '123456',
      profession: 'Professional Cook',
      rating: 4.8,
      reviewsCount: 112,
      bio:
          'Experienced chef available for home cooking and special event catering.',
      specialties: ['Cooking'],
      serviceImage: 'assets/images/cooking.png',
    ),
    const UserModel(
      id: 'user_9',
      name: 'Maria Garcia',
      email: 'maria@gmail.com',
      phone: '+91 1234567890',
      userType: UserType.serviceBoy,
      otp: '123456',
      profession: 'Expert Painter',
      rating: 4.7,
      reviewsCount: 95,
      bio:
          'Detail-oriented painter for interior and exterior home transformations.',
      specialties: ['Painter', 'Cleaning'],
      serviceImage: 'assets/images/painting_service.png',
    ),
    const UserModel(
      id: 'user_10',
      name: 'Alex Brown',
      email: 'alex@gmail.com',
      phone: '+91 9876543210',
      userType: UserType.serviceBoy,
      otp: '123456',
      profession: 'HVAC Technician',
      rating: 4.5,
      reviewsCount: 64,
      bio: 'Specialist in AC installation, repair, and maintenance services.',
      specialties: ['Ac Repair', 'Electrician'],
      serviceImage: 'assets/images/ac_repair_service.png',
    ),
    const UserModel(
      id: 'user_11',
      name: 'Sameer Khan',
      email: 'sameer@gmail.com',
      phone: '+91 9876543210',
      userType: UserType.serviceBoy,
      otp: '123456',
      profession: 'Male Grooming Expert',
      rating: 4.6,
      reviewsCount: 88,
      bio: 'Professional barber and grooming specialist for men.',
      specialties: ['Salon', 'Grooming'],
      serviceImage: 'assets/images/saloon.png',
    ),
    const UserModel(
      id: 'user_12',
      name: 'Kevin Peters',
      email: 'kevin@gmail.com',
      phone: '+91 9876543210',
      userType: UserType.serviceBoy,
      otp: '123456',
      profession: 'Furniture Specialist',
      rating: 4.8,
      reviewsCount: 145,
      bio: 'Master carpenter for furniture assembly and restoration.',
      specialties: ['Carpenter', 'Electrician'],
      serviceImage: 'assets/images/smart_home_install.png',
    ),
  ];

  // Get all users based on type
  List<UserModel> getUsersByType(UserType type) {
    return _dummyUsers.where((u) => u.userType == type).toList();
  }

  // Get providers for a specific category
  List<UserModel> getProvidersByCategory(String category) {
    return _dummyUsers
        .where(
          (u) =>
              u.userType == UserType.serviceBoy &&
              u.specialties.any(
                (s) => s.toLowerCase() == category.toLowerCase(),
              ),
        )
        .toList();
  }

  // Get service providers sorted by rating (highest first)
  List<UserModel> getProvidersByRating({int? limit}) {
    final providers =
        _dummyUsers.where((u) => u.userType == UserType.serviceBoy).toList()
          ..sort((a, b) => b.rating.compareTo(a.rating));

    if (limit != null && limit > 0) {
      return providers.take(limit).toList();
    }
    return providers;
  }

  // Normalize phone number for comparison (strip non-digits)
  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'\D'), '');
  }

  // Compare identifiers (email or phone)
  bool _compareIdentifiers(String stored, String provided) {
    if (stored.contains('@') && provided.contains('@')) {
      return stored.toLowerCase() == provided.toLowerCase();
    }
    // Assume phone number comparison
    final normalizedStored = _normalizePhone(stored);
    final normalizedProvided = _normalizePhone(provided);

    // Handle cases where one might have a country code and the other doesn't
    if (normalizedStored.length > normalizedProvided.length) {
      return normalizedStored.endsWith(normalizedProvided);
    } else {
      return normalizedProvided.endsWith(normalizedStored);
    }
  }

  // Find user by identifier (email or phone) and type
  UserModel? findUser(String identifier, UserType userType) {
    try {
      return [..._dummyUsers].firstWhere(
        (user) =>
            user.userType == userType &&
            (_compareIdentifiers(user.phone, identifier) ||
                _compareIdentifiers(user.email!, identifier)),
      );
    } catch (e) {
      return null;
    }
  }

  // Robust OTP verification
  bool verifyOTP(String identifier, UserType userType, String otp) {
    final user = findUser(identifier, userType);
    if (user == null) return false;
    return user.otp!.trim() == otp.trim();
  }

  // Alias for legacy support if needed, but redirects to proper logic
  bool vrifyotpuser(String identifier, UserType userType, String otp) {
    return verifyOTP(identifier, userType, otp);
  }

  // Get OTP hint for testing (in production, this would be removed)
  String? getOTPHint(String identifier, UserType userType) {
    final user = findUser(identifier, userType);
    return user?.otp;
  }

  // Get user data after successful authentication
  UserModel? getUserData(String identifier, UserType userType) {
    return findUser(identifier, userType);
  }

  // Get all dummy accounts for display
  List<UserModel> getAllUsers() {
    return [..._dummyUsers];
  }

  // Find user by identifier automatically (checks both user types)
  UserModel? findUserAnyType(String identifier) {
    try {
      return [
        ..._dummyUsers,
      ].firstWhere((user) => _compareIdentifiers(user.phone, identifier));
    } catch (e) {
      return null;
    }
  }
}
