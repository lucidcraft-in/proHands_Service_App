import 'package:flutter/material.dart';
import '../models/quotation_model.dart';
import '../services/quotation_service.dart';

class QuotationProvider extends ChangeNotifier {
  final QuotationService _service = QuotationService();

  List<QuotationModel> _quotations = [];
  bool _isLoading = false;
  String? _error;

  bool _isCreating = false;
  String? _createError;

  bool _isSubmitting = false;
  String? _submitError;

  // Getters
  List<QuotationModel> get quotations => _quotations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isCreating => _isCreating;
  String? get createError => _createError;

  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;

  // Fetch Quotations
  Future<void> fetchQuotations({String? status, bool showSilent = false}) async {
    if (!showSilent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final fetched = await _service.fetchQuotations(status: status);
      _quotations = fetched;
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create Quotation Request
  Future<bool> createRequest({
    required String customerId,
    required String serviceId,
    required String locationName,
    required String city,
    required double latitude,
    required double longitude,
    String? description,
    String? notes,
    String? category,
    String? subcategory,
    String? serviceName,
    List<String>? images,
    List<String>? technicianIds,
  }) async {
    _isCreating = true;
    _createError = null;
    notifyListeners();

    try {
      final quotation = await _service.createQuotationRequest(
        customerId: customerId,
        serviceId: serviceId,
        locationName: locationName,
        city: city,
        latitude: latitude,
        longitude: longitude,
        description: description,
        notes: notes,
        category: category,
        subcategory: subcategory,
        serviceName: serviceName,
        images: images,
        technicianIds: technicianIds,
      );
      // Insert at front
      _quotations.insert(0, quotation);
      return true;
    } catch (e) {
      _createError = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  // Submit Quotation Details (Technician)
  Future<bool> submitDetails({
    required String quotationId,
    required double amount,
    String? technicianNote,
    List<String>? attachments,
  }) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    try {
      final updated = await _service.submitQuotationDetails(
        quotationId: quotationId,
        amount: amount,
        technicianNote: technicianNote,
        attachments: attachments,
      );
      
      // Update item in list
      final index = _quotations.indexWhere((q) => q.id == quotationId);
      if (index != -1) {
        _quotations[index] = updated;
      }
      return true;
    } catch (e) {
      _submitError = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // Customer Rejects Quotation
  Future<bool> rejectQuotation(String quotationId) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    try {
      final updated = await _service.rejectQuotation(quotationId);
      
      // Update item in list
      final index = _quotations.indexWhere((q) => q.id == quotationId);
      if (index != -1) {
        _quotations[index] = updated;
      }
      return true;
    } catch (e) {
      _submitError = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // Customer Converts Quotation to Booking
  Future<Map<String, dynamic>?> convertToBooking({
    required String quotationId,
    required String date,
    required String time,
    String? technicianId,
  }) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    try {
      final result = await _service.convertQuotationToBooking(
        quotationId: quotationId,
        date: date,
        time: time,
        technicianId: technicianId,
      );

      // Update list
      if (result.containsKey('quotation')) {
        final updated = QuotationModel.fromJson(result['quotation']);
        final index = _quotations.indexWhere((q) => q.id == quotationId);
        if (index != -1) {
          _quotations[index] = updated;
        }
      }
      return result;
    } catch (e) {
      _submitError = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // Upload Attachments
  Future<List<String>> uploadAttachments(List<String> filePaths) async {
    try {
      return await _service.uploadMultipleFiles(filePaths);
    } catch (e) {
      _submitError = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  // Fetch single quotation details
  Future<QuotationModel?> fetchQuotationDetails(String quotationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final quotation = await _service.fetchQuotationDetails(quotationId);
      
      // Update item in list
      final index = _quotations.indexWhere((q) => q.id == quotationId);
      if (index != -1) {
        _quotations[index] = quotation;
      } else {
        _quotations.insert(0, quotation);
      }
      return quotation;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
