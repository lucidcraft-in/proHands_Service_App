import 'package:flutter/material.dart';

/// App color palette matching the design references
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF5B7FFF);
  static const Color primaryDark = Color(0xFF4A6AE8);
  static const Color primaryLight = Color(0xFF7A9AFF);
  
  // Secondary/Accent Colors
  static const Color orange = Color(0xFFFF6B52);
  static const Color orangeLight = Color(0xFFFF8A76);
  static const Color cyan = Color(0xFF52D4FF);
  static const Color cyanLight = Color(0xFF76DEFF);
  static const Color purple = Color(0xFF9B7FFF);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFFF8F9FD);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1A1D1F);
  static const Color textSecondary = Color(0xFF6F767E);
  static const Color textTertiary = Color(0xFF9A9FA5);
  static const Color textHint = Color(0xFFB8BCC3);
  
  // Status Colors
  static const Color success = Color(0xFF2FCC71);
  static const Color successLight = Color(0xFFE8F8EF);
  static const Color warning = Color(0xFFFFA928);
  static const Color warningLight = Color(0xFFFFF4E5);
  static const Color error = Color(0xFFFF4B4B);
  static const Color errorLight = Color(0xFFFFE8E8);
  static const Color info = Color(0xFF5B7FFF);
  static const Color infoLight = Color(0xFFE8EDFF);
  
  // Border & Divider Colors
  static const Color border = Color(0xFFE8ECF4);
  static const Color borderDark = Color(0xFFD1D5DB);
  static const Color divider = Color(0xFFEFEFF0);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF5B7FFF), Color(0xFF7A9AFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient balanceGradient = LinearGradient(
    colors: [Color(0xFF5B7FFF), Color(0xFF9B7FFF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFFF6B52), Color(0xFFFF8A76)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF52D4FF), Color(0xFF76DEFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);
}
