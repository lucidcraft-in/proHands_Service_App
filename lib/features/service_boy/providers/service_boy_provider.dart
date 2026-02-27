import 'dart:io';
import 'package:flutter/material.dart';
import '../models/service_category_model.dart';
import '../models/service_model.dart';
import '../models/gallery_image_model.dart';
import '../services/service_boy_service.dart';
import '../../../core/models/booking_model.dart';

class ServiceBoyProvider extends ChangeNotifier {
  final ServiceBoyService _service = ServiceBoyService();

  List<ServiceCategoryModel> _categories = [];
  bool _isLoadingCategories = false;
  String? _categoriesError;

  List<ServiceModel> _myServices = [];
  bool _isLoadingServices = false;
  String? _servicesError;

  bool _isCreatingService = false;
  String? _createServiceError;

  // Getters
  List<ServiceCategoryModel> get categories => _categories;
  bool get isLoadingCategories => _isLoadingCategories;
  String? get categoriesError => _categoriesError;

  List<ServiceModel> get myServices => _myServices;
  bool get isLoadingServices => _isLoadingServices;
  String? get servicesError => _servicesError;

  bool get isCreatingService => _isCreatingService;
  String? get createServiceError => _createServiceError;

  // Fetch Categories
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

  // Create Service
  Future<bool> createService(Map<String, dynamic> serviceData) async {
    _isCreatingService = true;
    _createServiceError = null;
    notifyListeners();

    try {
      await _service.createService(serviceData);
      // Refresh list
      await fetchMyServices();
      return true;
    } catch (e) {
      _createServiceError = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isCreatingService = false;
      notifyListeners();
    }
  }

  // Upload Service Image
  Future<String?> uploadServiceImage(File imageFile) async {
    _isCreatingService = true;
    _createServiceError = null;
    notifyListeners();

    try {
      final url = await _service.uploadImage(imageFile);
      return url;
    } catch (e) {
      _createServiceError = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _isCreatingService = false;
      notifyListeners();
    }
  }

  // Fetch My Services
  Future<void> fetchMyServices() async {
    print("-- ---- --");
    _isLoadingServices = true;
    _servicesError = null;
    notifyListeners();

    try {
      _myServices = await _service.getMyServices();
      print(_myServices);
    } catch (e) {
      _servicesError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingServices = false;
      notifyListeners();
    }
  }

  // Bookings State
  List<BookingModel> _bookings = [];
  bool _isLoadingBookings = false;
  String? _bookingsError;

  List<BookingModel> get bookings => _bookings;
  bool get isLoadingBookings => _isLoadingBookings;
  String? get bookingsError => _bookingsError;

  // Filtered Bookings
  List<BookingModel> get pendingBookings =>
      _bookings.where((b) => b.status == BookingStatus.pending).toList();

  List<BookingModel> get ongoingBookings =>
      _bookings.where((b) => b.status == BookingStatus.ongoing).toList();

  List<BookingModel> get completedBookings =>
      _bookings.where((b) => b.status == BookingStatus.completed).toList();

  List<BookingModel> get cancelledBookings =>
      _bookings.where((b) => b.status == BookingStatus.cancelled).toList();

  Future<void> fetchBookings() async {
    _isLoadingBookings = true;
    _bookingsError = null;
    notifyListeners();

    try {
      _bookings = await _service.getBookings();
    } catch (e) {
      _bookingsError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingBookings = false;
      notifyListeners();
    }
  }

  // Accept Booking
  Future<bool> acceptBooking(String bookingId) async {
    try {
      final success = await _service.updateBookingStatus(bookingId, 'ACCEPTED');
      if (success) {
        // Refresh bookings to update the UI
        await fetchBookings();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // Handle error gracefully or rethrow if needed
      return false;
    }
  }

  // Verify Booking OTP
  Future<bool> verifyBookingOtp(
    String bookingId,
    Map<String, dynamic> verificationData,
  ) async {
    try {
      final success = await _service.verifyBookingOtp(
        bookingId,
        verificationData,
      );
      if (success) {
        // Refresh bookings to update the UI (move to completed)
        await fetchBookings();
        // Refresh dashboard stats as well
        await fetchDashboardStats();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      _bookingsError = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // Booking Details State
  BookingModel? _selectedBooking;
  bool _isLoadingBookingDetails = false;
  String? _bookingDetailsError;

  BookingModel? get selectedBooking => _selectedBooking;
  bool get isLoadingBookingDetails => _isLoadingBookingDetails;
  String? get bookingDetailsError => _bookingDetailsError;

  Future<void> fetchBookingDetails(String bookingId) async {
    _isLoadingBookingDetails = true;
    _bookingDetailsError = null;
    _selectedBooking = null; // Reset previous selection
    notifyListeners();

    try {
      _selectedBooking = await _service.getBookingDetails(bookingId);
    } catch (e) {
      _bookingDetailsError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingBookingDetails = false;
      notifyListeners();
    }
  }

  // Service Details State
  ServiceModel? _selectedService;
  bool _isLoadingServiceDetails = false;
  String? _serviceDetailsError;

  ServiceModel? get selectedService => _selectedService;
  bool get isLoadingServiceDetails => _isLoadingServiceDetails;
  String? get serviceDetailsError => _serviceDetailsError;

  Future<void> fetchServiceDetails(String serviceId) async {
    _isLoadingServiceDetails = true;
    _serviceDetailsError = null;
    _selectedService = null;
    notifyListeners();

    try {
      _selectedService = await _service.getServiceDetails(serviceId);
    } catch (e) {
      _serviceDetailsError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingServiceDetails = false;
      notifyListeners();
    }
  }

  // Dashboard Stats State
  Map<String, dynamic>? _dashboardStats;
  bool _isLoadingStats = false;
  String? _statsError;

  Map<String, dynamic>? get dashboardStats => _dashboardStats;
  bool get isLoadingStats => _isLoadingStats;
  String? get statsError => _statsError;

  Future<void> fetchDashboardStats() async {
    _isLoadingStats = true;
    _statsError = null;
    notifyListeners();

    try {
      _dashboardStats = await _service.getDashboardStats();
    } catch (e) {
      _statsError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  // Gallery Upload State
  bool _isUploadingGallery = false;
  String? _uploadGalleryError;

  bool get isUploadingGallery => _isUploadingGallery;
  String? get uploadGalleryError => _uploadGalleryError;

  Future<bool> uploadGalleryImage(
    File imageFile,
    String description,
    String serviceId,
  ) async {
    _isUploadingGallery = true;
    _uploadGalleryError = null;
    notifyListeners();

    try {
      final success = await _service.uploadGalleryImage(
        imageFile,
        description,
        serviceId,
      );
      return success;
    } catch (e) {
      _uploadGalleryError = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isUploadingGallery = false;
      notifyListeners();
    }
  }

  // Gallery Fetch State
  List<GalleryImageModel> _galleryImages = [];
  bool _isLoadingGallery = false;
  String? _galleryError;

  List<GalleryImageModel> get galleryImages => _galleryImages;
  bool get isLoadingGallery => _isLoadingGallery;
  String? get galleryError => _galleryError;

  // Fetch gallery images for a specific provider
  Future<void> fetchGalleryImages(String providerId) async {
    _isLoadingGallery = true;
    _galleryError = null;
    notifyListeners();

    try {
      _galleryImages = await _service.getGalleryImages(providerId);
    } catch (e) {
      _galleryError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingGallery = false;
      notifyListeners();
    }
  }
}
