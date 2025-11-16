import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:obppay/model/user_model.dart';
import 'dart:convert';
import '../services/api.dart';

class UserProvider extends ChangeNotifier {
  UserModel user = UserModel.empty();
  final storage = const FlutterSecureStorage();
  String? token;

  double score = 0;
  int lastPoints = 0;



  bool isLoading = false;


  Future<void> fetchScore() async {
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse("${Api.baseUrl}/user/score/latest"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        lastPoints = data["last_points"] ?? 0;
        score = double.tryParse(data["score"].toString()) ?? 0;

        notifyListeners();
      }
    } catch (_) {}
  }


  Future<void> loadUserFromApi() async {
    isLoading = true;
    notifyListeners();

    try {
      final storedToken = await storage.read(key: "token");
      print("🔹 TOKEN IN PROVIDER → $storedToken");

      token = storedToken;

      if (token == null) {
        isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse("${Api.baseUrl}/auth/me"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        user = UserModel.fromJson(data);
      }
    } catch (e) {
      print("LOAD USER ERROR → $e");
    }

    isLoading = false;
    notifyListeners();
  }

// -------------------------------
  // UPDATE USER LOCALLY AFTER EDIT PROFILE
  // -------------------------------
  // ----------------------------------------------------
  // UPDATE USER LOCALLY AFTER EDIT PROFILE
  // ----------------------------------------------------
  void updateUser(String newName, String newPhone) {
    // user ne peut jamais être null car on utilise UserModel.empty()

    user = user.copyWith(
      fullName: newName,
      phone: newPhone,
    );

    notifyListeners();
  }

  void updateBalance(double newBalance) {
    user = user.copyWith(
      balance: newBalance,   // requires your UserModel to support this field
    );

    notifyListeners();
  }


  Future<void> logout() async {
    try {
      final token = await storage.read(key: "token");

      await http.post(
        Uri.parse("${Api.baseUrl}/auth/logout"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );
    } catch (_) {}

    await storage.delete(key: "token");
    user = UserModel.empty();

    notifyListeners();
  }



}
