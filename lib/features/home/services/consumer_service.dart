import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../../service_boy/models/service_category_model.dart';
import '../models/service_product_model.dart';
import '../models/feed_model.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/review_model.dart';

class ConsumerService {
  final String baseUrl = AuthService.baseUrl;

  // Get headers with token
  Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getAuthToken();
    print(token);
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get Categories
  Future<List<ServiceCategoryModel>> getCategories() async {
    final url = Uri.parse('$baseUrl/services/categories');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> categoriesJson = data['categories'];
          return categoriesJson
              .map((json) => ServiceCategoryModel.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load categories');
        }
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  // Get Services by Category
  Future<List<ServiceProductModel>> getServicesByCategory(
    String categoryId,
  ) async {
    print(categoryId);
    final url = Uri.parse('$baseUrl/services/category/$categoryId');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        if (data['success'] == true) {
          final List<dynamic> servicesJson = data['services'];
          return servicesJson
              .map((json) => ServiceProductModel.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load services');
        }
      } else {
        throw Exception('Failed to load services: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching services: $e');
    }
  }

  // Get Trending Services
  Future<List<ServiceProductModel>> getTrendingServices() async {
    final url = Uri.parse('$baseUrl/services/trending');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> servicesJson = data['services'];
          return servicesJson
              .map((json) => ServiceProductModel.fromJson(json))
              .toList();
        } else {
          throw Exception(
            data['message'] ?? 'Failed to load trending services',
          );
        }
      } else {
        throw Exception(
          'Failed to load trending services: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching trending services: $e');
    }
  }

  // Get My Bookings
  Future<List<BookingModel>> getMyBookings() async {
    final url = Uri.parse('$baseUrl/bookings/my-bookings');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> bookingsJson = data['bookings'];
          return bookingsJson
              .map((json) => BookingModel.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load bookings');
        }
      } else {
        throw Exception('Failed to load bookings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  // Get single booking details
  Future<BookingModel> getBookingDetails(String id) async {
    final url = Uri.parse('$baseUrl/bookings/$id');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return BookingModel.fromJson(data['booking']);
        } else {
          throw Exception(data['message'] ?? 'Failed to load booking details');
        }
      } else {
        throw Exception(
          'Failed to load booking details: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching booking details: $e');
    }
  }

  // Create a new booking
  Future<List<FeedModel>> getFeeds({int page = 1, int limit = 10}) async {
    final url = Uri.parse('$baseUrl/feeds?page=$page&limit=$limit');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> feedsJson = data['feeds'];
          return feedsJson.map((json) => FeedModel.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load feeds');
        }
      } else {
        throw Exception('Failed to load feeds: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching feeds: $e');
    }
  }

  // Update Profile
  Future<UserModel> updateProfile({
    required String name,
    required String email,
    required String address,
  }) async {
    final url = Uri.parse('$baseUrl/users/me');
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'name': name,
        'email': email,
        'address': address,
      });

      final response = await http.patch(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return UserModel.fromJson(data['user']);
        } else {
          throw Exception(data['message'] ?? 'Failed to update profile');
        }
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  // Complete Provider Profile
  Future<UserModel> completeProviderProfile({
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
    final url = Uri.parse('$baseUrl/auth/complete-profile');
    try {
      final token = await StorageService.getAuthToken();
      final request = http.MultipartRequest('POST', url);

      // Headers
      request.headers['Authorization'] = 'Bearer $token';

      // Fields
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['address'] = address;
      request.fields['profession'] = profession;
      request.fields['experience'] = experience;
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();

      // JSON encoded fields
      // ServicesOffered, WorkPreference, WorkLocationPreferred might need to be sent as JSON strings or individual array items
      // Based on typical multipart handling, we often send array items as 'key[]': value or similar.
      // However, if backend expects JSON string:
      request.fields['servicesOffered'] = jsonEncode(servicesOffered);
      request.fields['workPreference'] = jsonEncode(workPreference);
      request.fields['workLocationPreferred'] = jsonEncode(
        workLocationPreferred,
      );

      // Files
      if (adharCardPath != null) {
        request.files.add(
          await http.MultipartFile.fromPath('adharCard', adharCardPath),
        );
      }
      if (licensePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath('license', licensePath),
        );
      }
      if (serviceImagePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath('serviceImage', serviceImagePath),
        );
      }
      if (portfolioImagePaths != null) {
        for (var path in portfolioImagePaths) {
          request.files.add(
            await http.MultipartFile.fromPath('portfolioImages', path),
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print(data);
        if (data['success'] == true) {
          // The response might contain the updated user or token
          // Assuming it returns updated user data
          // If the structure is different, adjust accordingly.
          // Based on typical auth/complete-profile responses, it might return user object.
          if (data['user'] != null) {
            return UserModel.fromJson(data['user']);
          } else {
            // If no user returned, maybe just success? Fetch me again?
            return await getMe();
          }
        } else {
          throw Exception(data['message'] ?? 'Failed to complete profile');
        }
      } else {
        throw Exception(
          'Failed to complete profile: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error completing profile: $e');
    }
  }

  // Update Location
  Future<UserModel> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse('$baseUrl/users/me');
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({'latitude': latitude, 'longitude': longitude});

      final response = await http.patch(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return UserModel.fromJson(data['user']);
        } else {
          throw Exception(data['message'] ?? 'Failed to update location');
        }
      } else {
        throw Exception('Failed to update location: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating location: $e');
    }
  }

  // Get Provider by ID
  Future<UserModel> getMe() async {
    final url = Uri.parse('$baseUrl/users/me');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return UserModel.fromJson(data['user']);
        } else {
          throw Exception(data['message'] ?? 'Failed to load user profile');
        }
      } else {
        throw Exception('Failed to load user profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }

  Future<UserModel> getProviderById(String id) async {
    final url = Uri.parse('$baseUrl/users/providers/$id');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return UserModel.fromJson(data['provider']);
        } else {
          throw Exception(data['message'] ?? 'Failed to load provider details');
        }
      } else {
        throw Exception(
          'Failed to load provider details: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching provider details: $e');
    }
  }

  // Create Booking
  Future<Map<String, dynamic>> createBooking({
    required String serviceId,
    required String date,
    required String time,
    required String address,
    required List<double> coordinates,
  }) async {
    final url = Uri.parse('$baseUrl/bookings');
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'serviceId': serviceId,
        'date': date,
        'time': time,
        'location': {'address': address, 'coordinates': coordinates},
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data;
        } else {
          throw Exception(data['message'] ?? 'Failed to create booking');
        }
      } else {
        throw Exception('Failed to create booking: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating booking: $e');
    }
  }

  // Get My Reviews (added or received)
  Future<List<ReviewModel>> getMyReviews(bool isServiceBoy) async {
    final endpoint =
        isServiceBoy ? '/reviews/my/received' : '/reviews/my/added';
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> reviewsJson = data['reviews'] ?? [];
          return reviewsJson.map((json) => ReviewModel.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load reviews');
        }
      } else {
        throw Exception('Failed to load reviews: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
    }
  }

  Future<bool> addReview({
    required String bookingId,
    required double rating,
    required String comment,
    List<String>? imagePaths,
  }) async {
    final url = Uri.parse('$baseUrl/reviews');
    try {
      final token = await StorageService.getAuthToken();
      final request = http.MultipartRequest('POST', url);

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['bookingId'] = bookingId;
      request.fields['rating'] = rating.toString();
      request.fields['comment'] = comment;

      if (imagePaths != null && imagePaths.isNotEmpty) {
        for (var path in imagePaths) {
          request.files.add(await http.MultipartFile.fromPath('images', path));
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to submit review');
      }
    } catch (e) {
      throw Exception('Error submitting review: $e');
    }
  }

  // Cancel Booking Request
  Future<bool> cancelBookingRequest(String bookingId, String reason) async {
    final url = Uri.parse('$baseUrl/bookings/$bookingId/cancel-request');
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({'reason': reason});
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to requested cancellation');
      }
    } catch (e) {
      throw Exception('Error requesting cancellation: $e');
    }
  }
}
