import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_type.dart';

class StorageService {
  static const String _authTokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _userTypeKey = 'user_type';

  static Future<void> saveUserType(UserType userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userTypeKey, userType.name);
  }

  static Future<UserType?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    final userTypeName = prefs.getString(_userTypeKey);
    if (userTypeName == null) return null;

    try {
      return UserType.values.byName(userTypeName);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(userData));
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);
    if (userDataString == null) return null;
    return jsonDecode(userDataString);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null;
  }

  static Future<void> saveUserLocation({
    required String address,
    required List<double> coordinates,
    String? label,
    String? zipcode,
    String? locality,
    String? administrativeArea,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    // Get existing locations
    List<Map<String, dynamic>> locations = await getSavedLocations();

    // Check if address already exists to avoid duplicates
    final existingIndex = locations.indexWhere(
      (loc) => loc['address'] == address,
    );
    if (existingIndex != -1) {
      // Move to top if exists
      locations.removeAt(existingIndex);
    }
    print("=======");
    print(label);
    // Add new location to top
    locations.insert(0, {
      'address': address,
      'coordinates': coordinates,
      'label':
          (label != null && label.isNotEmpty)
              ? label
              : (locality != null && locality.isNotEmpty)
              ? locality
              : 'Saved Location',
      'zipcode': zipcode,
      'locality': locality,
      'administrativeArea': administrativeArea,
    });

    await prefs.setString('saved_locations', jsonEncode(locations));
  }

  static Future<List<Map<String, dynamic>>> getSavedLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final locationsString = prefs.getString('saved_locations');
    if (locationsString == null) return [];
    try {
      final List<dynamic> list = jsonDecode(locationsString);
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  static Future<void> removeSavedLocation(String address) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> locations = await getSavedLocations();
    locations.removeWhere((loc) => loc['address'] == address);
    await prefs.setString('saved_locations', jsonEncode(locations));
  }

  // Deprecated/Legacy method for backward compatibility if needed, using the first saved location
  static Future<Map<String, dynamic>?> getUserLocation() async {
    final locations = await getSavedLocations();
    if (locations.isNotEmpty) {
      return locations.first;
    }
    return null;
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
