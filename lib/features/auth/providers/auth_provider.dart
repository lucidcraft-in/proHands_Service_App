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

  Future<void> login(String phone, UserType userType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthService.requestOTP(phone, userType.apiValue);
      print(response);
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

  Future<void> verifyOtp(String phone, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthService.verifyOTP(phone, otp);
      print(response);
      final token = response['token'];
      final userData = response['user'];
      print("--------------------- -------------------");
      print(userData);
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
      print(e);
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
