import 'package:flutter/material.dart';
import 'package:obppay/themes/app_colors.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: "SFPro",


  // --- MAIN COLORS ---
  primaryColor: AppColors.primaryIndigo,
  scaffoldBackgroundColor: const Color(0xFF0E0E0E),

  colorScheme: const ColorScheme.dark(
    primary: AppColors.primaryIndigo,
    secondary: AppColors.accentGold,
    background: Color(0xFF0E0E0E),
    surface: Color(0xFF1A1A1A),
  ),

  // --- APPBAR ---
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF101010),
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),

  // --- INPUT FIELDS ---
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.primaryIndigo, width: 2),
    ),
    labelStyle: const TextStyle(color: Colors.white70),
  ),

  // --- ELEVATED BUTTONS ---
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryIndigo,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
    ),
  ),
);
