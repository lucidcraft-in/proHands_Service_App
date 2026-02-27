import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/booking_model.dart';
import '../models/service_category_model.dart';
import '../models/service_model.dart';
import '../models/gallery_image_model.dart';

class ServiceBoyService {
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

  // Create Service
  Future<Map<String, dynamic>> createService(
    Map<String, dynamic> serviceData,
  ) async {
    final url = Uri.parse('$baseUrl/services');
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(serviceData),
      );

      final data = jsonDecode(response.body);
      print(data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['success'] == true) {
          return data;
        } else {
          throw Exception(data['message'] ?? 'Failed to create service');
        }
      } else {
        throw Exception(
          data['message'] ?? 'Failed to create service: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error creating service: $e');
    }
  }

  // Get My Services
  Future<List<ServiceModel>> getMyServices() async {
    final url = Uri.parse('$baseUrl/services/my-services');
    try {
      final headers = await _getHeaders();
      print(url);
      print(headers);
      final response = await http.get(url, headers: headers);
      print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("-------  ---- ");
        print(data);
        if (data['success'] == true) {
          final List<dynamic> servicesJson = data['services'] ?? [];
          return servicesJson
              .map((json) => ServiceModel.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get Bookings
  Future<List<BookingModel>> getBookings() async {
    final url = Uri.parse('$baseUrl/bookings');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print(data['bookings']);
          final List<dynamic> bookingsJson = data['bookings'];
          print("------- -------");
          print(bookingsJson);
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

  // Update Booking Status
  Future<bool> updateBookingStatus(String bookingId, String status) async {
    final url = Uri.parse('$baseUrl/bookings/$bookingId/status');
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode({'status': status}),
      );
      print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        throw Exception(
          'Failed to update booking status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error updating booking status: $e');
    }
  }

  // Verify Booking OTP
  Future<bool> verifyBookingOtp(
    String bookingId,
    Map<String, dynamic> verificationData,
  ) async {
    final url = Uri.parse('$baseUrl/bookings/$bookingId/verify');
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(verificationData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        final data = jsonDecode(response.body); // Try to get error message
        throw Exception(
          data['message'] ?? 'Failed to verify OTP: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error verifying OTP: $e');
    }
  }

  // Get Booking Details
  Future<BookingModel> getBookingDetails(String bookingId) async {
    final url = Uri.parse('$baseUrl/bookings/$bookingId');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);
      print(response.body);
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

  // Get Service Details
  Future<ServiceModel> getServiceDetails(String serviceId) async {
    final url = Uri.parse('$baseUrl/services/$serviceId');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return ServiceModel.fromJson(data['service']);
        } else {
          throw Exception(data['message'] ?? 'Failed to load service details');
        }
      } else {
        throw Exception(
          'Failed to load service details: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching service details: $e');
    }
  }

  // Get Dashboard Stats
  Future<Map<String, dynamic>> getDashboardStats() async {
    final url = Uri.parse('$baseUrl/bookings/stats');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception(data['message'] ?? 'Failed to load stats');
        }
      } else {
        throw Exception('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching stats: $e');
    }
  }

  // Upload Image and return URL
  Future<String> uploadImage(File imageFile) async {
    final url = Uri.parse(
      '$baseUrl/gallery',
    ); // Reusing gallery for generic upload if possible
    try {
      final token = await StorageService.getAuthToken();
      final request = http.MultipartRequest('POST', url);

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['description'] = 'Service Image';

      final file = await http.MultipartFile.fromPath(
        'files', // Key expected by backend
        imageFile.path,
      );
      request.files.add(file);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print("-----------------------------------------------------");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print(data);
        if (data['success'] == true) {
          // If the backend returns multiple files, take the first one
          // if (data['files'] != null &&
          //     data['files'] is List &&
          //     data['files'].isNotEmpty) {
          //   return data['files'][0]['url'];
          // }
          // // Fallback if it's a single object
          // if (data['file'] != null) {
          //   return data['file']['url'];
          // }
          // Try gallery format
          if (data['galleryItems'] != null) {
            print("----------------------- ------------------------------");
            print(data['galleryItems'][0]['imageUrl']);
            return data['galleryItems'][0]['imageUrl'];
          }

          throw Exception('Image upload succeeded but no URL returned');
        } else {
          throw Exception(data['message'] ?? 'Failed to upload image');
        }
      } else {
        throw Exception(
          'Failed to upload image: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  // Upload Gallery Image
  Future<bool> uploadGalleryImage(
    File imageFile,
    String description,
    String serviceId,
  ) async {
    final url = Uri.parse('$baseUrl/gallery');
    try {
      final token = await StorageService.getAuthToken();
      final request = http.MultipartRequest('POST', url);

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['description'] = description;
      request.fields['serviceId'] = serviceId;

      final file = await http.MultipartFile.fromPath(
        'files', // Key expected by backend
        imageFile.path,
      );
      request.files.add(file);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        throw Exception(
          'Failed to upload image: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  // Get Gallery Images for a specific provider
  Future<List<GalleryImageModel>> getGalleryImages(String providerId) async {
    final url = Uri.parse('$baseUrl/gallery/provider/$providerId');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // The API response has gallery images nested in galleryImages.items
          final galleryData = data['galleryImages'];
          final List<dynamic> imagesJson =
              (galleryData != null && galleryData['items'] != null)
                  ? galleryData['items']
                  : [];
          return imagesJson
              .map((json) => GalleryImageModel.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load gallery images');
        }
      } else {
        throw Exception(
          'Failed to load gallery images: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching gallery images: $e');
    }
  }
}
