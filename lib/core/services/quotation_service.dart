import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
import 'auth_service.dart';
import 'storage_service.dart';
import '../models/quotation_model.dart';

class QuotationService {
  final String baseUrl = AuthService.baseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 1. Create a Quotation Request (Customer)
  Future<QuotationModel> createQuotationRequest({
    required String customerId,
    required String serviceId,
    required String locationName,
    required String city,
    required double latitude,
    required double longitude,
    String? description,
    String? notes,
  }) async {
    final url = Uri.parse('$baseUrl/quotations');
    final headers = await _getHeaders();
    final body = jsonEncode({
      'customerId': customerId,
      'serviceId': serviceId,
      'location': {
        'location_name': locationName,
        'city': city,
        'latitude': latitude,
        'longitude': longitude,
      },
      if (description != null) 'description': description,
      if (notes != null) 'notes': notes,
    });

    final response = await http.post(url, headers: headers, body: body);
    print("respponnse is : ${response.body}");
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return QuotationModel.fromJson(data['quotation']);
      } else {
        throw Exception(
          data['message'] ?? 'Failed to create quotation request',
        );
      }
    } else {
      try {
        final data = jsonDecode(response.body);
        throw Exception(
          data['message'] ??
              'Failed to create quotation: ${response.statusCode}',
        );
      } catch (_) {
        throw Exception(
          'Failed to create quotation request: Server error ${response.statusCode}',
        );
      }
    }
  }

  // 2. Technician Submits Quotation Details (Technician)
  Future<QuotationModel> submitQuotationDetails({
    required String quotationId,
    required double amount,
    String? technicianNote,
    List<String>? attachments,
  }) async {
    print(amount);
    print(technicianNote);
    print(attachments);
    final url = Uri.parse('$baseUrl/quotations/$quotationId/submit-details');
    final headers = await _getHeaders();
    final body = jsonEncode({
      'amount': amount,
      if (technicianNote != null) 'technicianNote': technicianNote,
      if (attachments != null) 'attachments': attachments,
    });

    final response = await http.patch(url, headers: headers, body: body);
    print(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return QuotationModel.fromJson(data['quotation']);
      } else {
        throw Exception(
          data['message'] ?? 'Failed to submit quotation details',
        );
      }
    } else {
      try {
        final data = jsonDecode(response.body);
        throw Exception(
          data['message'] ?? 'Failed to submit details: ${response.statusCode}',
        );
      } catch (_) {
        throw Exception(
          'Failed to submit details: Server error ${response.statusCode}',
        );
      }
    }
  }

  // 3. Customer Rejects Quotation (Customer)
  Future<QuotationModel> rejectQuotation(String quotationId) async {
    final url = Uri.parse('$baseUrl/quotations/$quotationId/reject');
    final headers = await _getHeaders();

    final response = await http.patch(
      url,
      headers: headers,
      body: jsonEncode({}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return QuotationModel.fromJson(data['quotation']);
      } else {
        throw Exception(data['message'] ?? 'Failed to reject quotation');
      }
    } else {
      try {
        final data = jsonDecode(response.body);
        throw Exception(
          data['message'] ?? 'Failed to reject: ${response.statusCode}',
        );
      } catch (_) {
        throw Exception(
          'Failed to reject quotation: Server error ${response.statusCode}',
        );
      }
    }
  }

  // 4. Customer Accepts Quotation & Converts to Booking (Customer)
  Future<Map<String, dynamic>> convertQuotationToBooking({
    required String quotationId,
    required String date,
    required String time,
  }) async {
    final url = Uri.parse('$baseUrl/quotations/$quotationId/convert');
    final headers = await _getHeaders();
    final body = jsonEncode({'date': date, 'time': time});

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data; // contains booking, quotation, and message
      } else {
        throw Exception(data['message'] ?? 'Failed to convert quotation');
      }
    } else {
      try {
        final data = jsonDecode(response.body);
        throw Exception(
          data['message'] ?? 'Failed to convert: ${response.statusCode}',
        );
      } catch (_) {
        throw Exception(
          'Failed to convert quotation: Server error ${response.statusCode}',
        );
      }
    }
  }

  // 5. Fetch Quotations (Customer / Technician)
  Future<List<QuotationModel>> fetchQuotations({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    String query = 'page=$page&limit=$limit';
    if (status != null && status.isNotEmpty) {
      query += '&status=$status';
    }

    final url = Uri.parse('$baseUrl/quotations?$query');
    final headers = await _getHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> list = data['quotations'] ?? [];
        return list.map((json) => QuotationModel.fromJson(json)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch quotations');
      }
    } else {
      try {
        final data = jsonDecode(response.body);
        throw Exception(
          data['message'] ??
              'Failed to fetch quotations: ${response.statusCode}',
        );
      } catch (_) {
        throw Exception(
          'Failed to fetch quotations: Server error ${response.statusCode}',
        );
      }
    }
  }

  // Upload Multiple Files to /api/uploads
  Future<List<String>> uploadMultipleFiles(List<String> filePaths) async {
    if (filePaths.isEmpty) return [];
    final url = Uri.parse('$baseUrl/uploads');
    try {
      final token = await StorageService.getAuthToken();
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';

      for (var filePath in filePaths) {
        final extension = p.extension(filePath).toLowerCase();
        print(extension);
        MediaType mediaType;
        if (extension == '.png') {
          mediaType = MediaType('image', 'png');
        } else if (extension == '.pdf') {
          mediaType = MediaType('application', 'pdf');
        } else if (extension == '.doc' || extension == '.docx') {
          mediaType = MediaType('application', 'msword');
        } else if (extension == '.xls' || extension == '.xlsx') {
          mediaType = MediaType('application', 'vnd.ms-excel');
        } else {
          // Default to image/jpeg
          mediaType = MediaType('image', 'jpeg');
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            'files',
            filePath,
            contentType: mediaType,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<String> urls = [];
          if (data['fileUrls'] != null && data['fileUrls'] is List) {
            for (var u in data['fileUrls']) {
              urls.add(u.toString());
            }
          } else if (data['urls'] != null && data['urls'] is List) {
            for (var u in data['urls']) {
              urls.add(u.toString());
            }
          } else if (data['files'] != null && data['files'] is List) {
            for (var f in data['files']) {
              if (f is Map && f['url'] != null) {
                urls.add(f['url'].toString());
              } else if (f is String) {
                urls.add(f);
              }
            }
          } else if (data['file'] != null) {
            if (data['file'] is Map && data['file']['url'] != null) {
              urls.add(data['file']['url'].toString());
            } else if (data['file'] is String) {
              urls.add(data['file']);
            }
          }
          return urls;
        } else {
          throw Exception(data['message'] ?? 'Failed to upload files');
        }
      } else {
        throw Exception('Failed to upload files: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading files: $e');
    }
  }
}
