import 'package:flutter/material.dart';
import '../../service_boy/models/service_category_model.dart';
import '../models/service_product_model.dart';
import '../models/feed_model.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/review_model.dart';
import '../services/consumer_service.dart';
import '../../../core/services/storage_service.dart';

class ConsumerProvider extends ChangeNotifier {
  final ConsumerService _service = ConsumerService();

  List<ServiceCategoryModel> _categories = [];
  bool _isLoadingCategories = false;
  String? _categoriesError;

  bool _isSubmittingReview = false;
  String? _reviewError;

  List<ServiceCategoryModel> get categories => _categories;
  bool get isLoadingCategories => _isLoadingCategories;
  String? get categoriesError => _categoriesError;

  bool get isSubmittingReview => _isSubmittingReview;
  String? get reviewError => _reviewError;

  Future<void> fetchCategories() async {
    _isLoadingCategories = true;
    _categoriesError = null;
    notifyListeners();

    try {
      _categories = await _service.getCategories();
    } catch (e) {
      _categoriesError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  // Services by Category
  List<ServiceProductModel> _services = [];
  bool _isLoadingServices = false;
  String? _servicesError;

  List<ServiceProductModel> get services => _services;
  bool get isLoadingServices => _isLoadingServices;
  String? get servicesError => _servicesError;

  Future<void> fetchServicesByCategory(String categoryId) async {
    _isLoadingServices = true;
    _servicesError = null;
    _services = []; // Clear previous
    notifyListeners();

    try {
      _services = await _service.getServicesByCategory(categoryId);
    } catch (e) {
      _servicesError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingServices = false;
      notifyListeners();
    }
  }

  // Trending Services
  List<ServiceProductModel> _trendingServices = [];
  bool _isLoadingTrendingServices = false;
  String? _trendingServicesError;

  List<ServiceProductModel> get trendingServices => _trendingServices;
  bool get isLoadingTrendingServices => _isLoadingTrendingServices;
  String? get trendingServicesError => _trendingServicesError;

  Future<void> fetchTrendingServices() async {
    _isLoadingTrendingServices = true;
    _trendingServicesError = null;
    notifyListeners();

    try {
      _trendingServices = await _service.getTrendingServices();
    } catch (e) {
      _trendingServicesError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingTrendingServices = false;
      notifyListeners();
    }
  }

  // My Bookings
  List<BookingModel> _bookings = [];
  bool _isLoadingBookings = false;
  String? _bookingsError;

  List<UserModel> _providers = [];
  bool _isLoadingProviders = false;

  List<BookingModel> get bookings => _bookings;
  bool get isLoadingBookings => _isLoadingBookings;
  String? get bookingsError => _bookingsError;

  List<UserModel> get providers => _providers;
  bool get isLoadingProviders => _isLoadingProviders;

  Future<void> fetchMyBookings() async {
    _isLoadingBookings = true;
    _bookingsError = null;
    notifyListeners();

    try {
      _bookings = await _service.getMyBookings();
      // Sort by date descending (newest first) if date is available
      // BookingModel date is formatted string, so might need parsing if we want robust sort
      // API usually returns sorted, but reliable client sort is better if we had DateTime objects
    } catch (e) {
      _bookingsError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingBookings = false;
      notifyListeners();
    }
  }

  // Feeds
  List<FeedModel> _feeds = [];
  bool _isLoadingFeeds = false;
  String? _feedsError;

  List<FeedModel> get feeds => _feeds;
  bool get isLoadingFeeds => _isLoadingFeeds;
  String? get feedsError => _feedsError;

  Future<void> fetchFeeds() async {
    _isLoadingFeeds = true;
    _feedsError = null;
    notifyListeners();

    try {
      _feeds = await _service.getFeeds();
    } catch (e) {
      _feedsError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingFeeds = false;
      notifyListeners();
    }
  }

  // Current User Profile
  UserModel? _currentUser;
  bool _isLoadingProfile = false;
  String? _profileError;

  UserModel? get currentUser => _currentUser;
  bool get isLoadingProfile => _isLoadingProfile;
  String? get profileError => _profileError;

  Future<void> fetchUserProfile() async {
    _isLoadingProfile = true;
    _profileError = null;
    notifyListeners();

    try {
      _currentUser = await _service.getMe();
    } catch (e) {
      _profileError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  // Reviews
  List<ReviewModel> _reviews = [];
  bool _isLoadingReviews = false;
  String? _reviewsError;

  List<ReviewModel> get reviews => _reviews;
  bool get isLoadingReviews => _isLoadingReviews;
  String? get reviewsError => _reviewsError;

  Future<void> fetchReviews(bool isServiceBoy) async {
    _isLoadingReviews = true;
    _reviewsError = null;
    notifyListeners();

    try {
      _reviews = await _service.getMyReviews(isServiceBoy);
    } catch (e) {
      _reviewsError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingReviews = false;
      notifyListeners();
    }
  }

  // Update Profile
  bool _isUpdatingProfile = false;
  String? _updateProfileError;

  bool get isUpdatingProfile => _isUpdatingProfile;
  String? get updateProfileError => _updateProfileError;

  Future<bool> updateProfile({
    required String name,
    required String email,
    required String address,
  }) async {
    _isUpdatingProfile = true;
    _updateProfileError = null;
    notifyListeners();

    try {
      _currentUser = await _service.updateProfile(
        name: name,
        email: email,
        address: address,
      );
      _isUpdatingProfile = false;
      notifyListeners();
      return true;
    } catch (e) {
      _updateProfileError = e.toString().replaceAll('Exception: ', '');
      _isUpdatingProfile = false;
      notifyListeners();
      return false;
    }
  }

  // Update User Location
  Future<bool> updateUserLocation({
    required double latitude,
    required double longitude,
    String? address, // Optional: Update address text too if provided
  }) async {
    _isUpdatingProfile = true;
    _updateProfileError = null;
    notifyListeners();

    try {
      _currentUser = await _service.updateLocation(
        latitude: latitude,
        longitude: longitude,
      );

      // Verify if address also needs to be updated in storage/backend
      // The API call currently only sends lat/long as per request.
      // If address is provided, we can also update it in local storage or make another call if needed.
      // For now, adhering strictly to request: update lat/long via API.

      // Also update Storage Service if needed for local persistence of "current location"
      // But typically StorageService.saveUserLocation is for the "selected" location for booking,
      // while this API updates the USER PROFILE location.
      if (address != null) {
        await StorageService.saveUserLocation(
          address: address,
          coordinates: [latitude, longitude],
        );
      }

      _isUpdatingProfile = false;
      notifyListeners();
      return true;
    } catch (e) {
      _updateProfileError = e.toString().replaceAll('Exception: ', '');
      _isUpdatingProfile = false;
      notifyListeners();
      return false;
    }
  }

  // Complete Provider Profile
  bool _isCompletingProfile = false;
  String? _completeProfileError;

  bool get isCompletingProfile => _isCompletingProfile;
  String? get completeProfileError => _completeProfileError;

  Future<bool> completeProviderProfile({
    required String name,
    required String email,
    required String address,
    required String profession,
    required String experience,
    required List<String> servicesOffered,
    required List<String> workPreference,
    required List<String> workLocationPreferred,
    required double latitude,
    required double longitude,
    String? adharCardPath,
    String? licensePath,
    String? serviceImagePath,
    List<String>? portfolioImagePaths,
  }) async {
    _isCompletingProfile = true;
    _completeProfileError = null;
    notifyListeners();

    try {
      _currentUser = await _service.completeProviderProfile(
        name: name,
        email: email,
        address: address,
        profession: profession,
        experience: experience,
        servicesOffered: servicesOffered,
        workPreference: workPreference,
        workLocationPreferred: workLocationPreferred,
        latitude: latitude,
        longitude: longitude,
        adharCardPath: adharCardPath,
        licensePath: licensePath,
        serviceImagePath: serviceImagePath,
        portfolioImagePaths: portfolioImagePaths,
      );
      _isCompletingProfile = false;
      notifyListeners();
      return true;
    } catch (e) {
      _completeProfileError = e.toString().replaceAll('Exception: ', '');
      _isCompletingProfile = false;
      notifyListeners();
      return false;
    }
  }

  // Create Booking
  bool _isCreatingBooking = false;
  String? _createBookingError;

  bool get isCreatingBooking => _isCreatingBooking;
  String? get createBookingError => _createBookingError;

  Future<bool> createBooking({
    required String serviceId,
    required String date,
    required String time,
    required String address,
    required List<double> coordinates,
  }) async {
    _isCreatingBooking = true;
    _createBookingError = null;
    notifyListeners();

    try {
      await _service.createBooking(
        serviceId: serviceId,
        date: date,
        time: time,
        address: address,
        coordinates: coordinates,
      );
      _isCreatingBooking = false;
      notifyListeners();
      return true;
    } catch (e) {
      _createBookingError = e.toString().replaceAll('Exception: ', '');
      _isCreatingBooking = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitReview({
    required String bookingId,
    required double rating,
    required String comment,
    List<String>? imagePaths,
  }) async {
    _isSubmittingReview = true;
    _reviewError = null;
    notifyListeners();

    try {
      final success = await _service.addReview(
        bookingId: bookingId,
        rating: rating,
        comment: comment,
        imagePaths: imagePaths,
      );
      _isSubmittingReview = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isSubmittingReview = false;
      _reviewError = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // Cancel Booking Request
  bool _isRequestingCancellation = false;
  String? _cancellationError;

  bool get isRequestingCancellation => _isRequestingCancellation;
  String? get cancellationError => _cancellationError;

  Future<bool> cancelBookingRequest({
    required String bookingId,
    required String reason,
  }) async {
    _isRequestingCancellation = true;
    _cancellationError = null;
    notifyListeners();

    try {
      final success = await _service.cancelBookingRequest(bookingId, reason);
      _isRequestingCancellation = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isRequestingCancellation = false;
      _cancellationError = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
