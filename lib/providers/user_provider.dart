import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:obppay/model/user_model.dart';
import 'package:obppay/services/wallet_service.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../services/api.dart';

class UserProvider extends ChangeNotifier {
  UserModel user = UserModel.empty();
  final storage = const FlutterSecureStorage();
  String? token;

  double score = 0;
  int lastPoints = 0;



  bool isLoading = false;

  int loanEligibility = 0; // 0 = not eligible, 1 = eligible
  String loanMessage = "";

  List<dynamic> transactions = [];

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


  Future<void> updateFcmToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    await http.post(
      Uri.parse("${Api.baseUrl}/user/update-fcm-token"),
      body: {
        "token": token,
      },
      headers: {"Authorization": "Bearer $token"},
    );
  }



  Future<void> loadTransactions() async {
    if (token == null) return;

    try {
      transactions = await WalletService.fetchTransactions(token!);
      notifyListeners();
    } catch (e) {
      print("❌ Error loading transactions: $e");
    }
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

        await checkLoanEligibility();
        await updateFcmToken();

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

  void updateUserProfile({
    required String fullName,
    required String phone,
    String? email,
  }) {
    user = user.copyWith(
      fullName: fullName,
      phone: phone,
      email: email,
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


  Future<void> checkLoanEligibility() async {
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse("${Api.baseUrl}/loan/eligibility"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        loanEligibility = data["eligibility"]; // 0 or 1
        loanMessage = data["message"];

        notifyListeners();
      }
    } catch (e) {
      print("Eligibility error → $e");
    }
  }

  Future<void> pickAndUploadProfileImage(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);

      if (file == null) return;

      final provider = context.read<UserProvider>();
      final user = provider.user;

      File imageFile = File(file.path);

      // ---- 1) Upload au backend ----
      final newUrl = await uploadProfileImage(imageFile, provider.token!);
      await provider.loadUserFromApi();
      // ---- 2) Mettre à jour l'objet user ----
      user.avatarUrl = newUrl;
      provider.notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Photo mise à jour avec succès !")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }
  }

  Future<String> uploadProfileImage(File file, String token) async {
    final url = "${Api.baseUrl}/user/update-photo";

    final request = http.MultipartRequest("POST", Uri.parse(url));
    request.headers["Authorization"] = "Bearer $token";

    request.files.add(await http.MultipartFile.fromPath("photo", file.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final json = jsonDecode(body);
      return json["avatar_url"]; // Doit matcher ton backend
    } else {
      throw "Upload failed (${response.statusCode})";
    }
  }



  Future<void> refreshUser() async {
    if (token == null) return;
    await loadUserFromApi();
  }






}
