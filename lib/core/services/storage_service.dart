import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_type.dart';

class StorageService {
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

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
