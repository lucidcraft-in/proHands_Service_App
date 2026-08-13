import 'package:flutter/material.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/user_type.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<void> login(String email, String phone, UserType userType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthService.requestOTP(
        email,
        phone,
        userType.apiValue,
      );

      // Save login details for next time
      await StorageService.saveLastLoginDetails(email, phone, userType);
      // API returns success message and debug_otp, but we don't need to store them here
      // The UI will handle navigation to OTP screen
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> verifyOtp(
    String email,
    String otp,
    String fcmToken,
    String phone,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthService.verifyOTP(email, otp, fcmToken, phone);
      final token = response['token'];
      final userData = response['user'];
      if (token != null && userData != null) {
        // Save to storage
        await StorageService.saveAuthToken(token);
        await StorageService.saveUserData(userData);

        // Parse user
        _currentUser = UserModel.fromJson(userData);

        // Save user type explicitly as well for quick access
        await StorageService.saveUserType(_currentUser!.userType);
      } else {
        throw Exception('Invalid response from server');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadUserFromStorage() async {
    final userData = await StorageService.getUserData();
    if (userData != null) {
      _currentUser = UserModel.fromJson(userData);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await StorageService.clearAll();
    _currentUser = null;
    notifyListeners();
  }
}
