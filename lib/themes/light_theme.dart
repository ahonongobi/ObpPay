import 'package:flutter/material.dart';
import 'package:obppay/themes/app_colors.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Inter',


  // --- MAIN COLORS ---
  primaryColor: AppColors.primaryIndigo,
  scaffoldBackgroundColor: Colors.white,

  colorScheme: const ColorScheme.light(
    primary: AppColors.primaryIndigo,
    secondary: AppColors.accentGold,
    background: Colors.white,
    surface: Colors.white,
  ),

  // --- APPBAR ---
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0.5,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),

  // --- INPUT FIELDS ---
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.primaryIndigo, width: 2),
    ),
    labelStyle: const TextStyle(color: Colors.black),
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
