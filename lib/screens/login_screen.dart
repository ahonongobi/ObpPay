import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:obppay/providers/user_provider.dart';
import 'package:obppay/screens/ForgetPasswordScreen.dart';
import 'package:obppay/screens/main_layout.dart';
import 'package:obppay/screens/regsiter_screen.dart';
import 'package:obppay/themes/app_colors.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:obppay/services/api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

final storage = FlutterSecureStorage();




const fakePhone = "1234567890";
const fakePassword = "1234pass";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _hidePassword = true;
  bool _loading = false;

  final LocalAuthentication auth = LocalAuthentication();


  void _login() async {
    final phone = _phoneController.text.trim();
    final pass = _passwordController.text.trim();

    if (phone.isEmpty || pass.isEmpty) {
      _showMessage("Veuillez remplir tous les champs.");
      return;
    }

    setState(() => _loading = true);

    try {
      final fcm = await FirebaseMessaging.instance.getToken();

      final response = await http.post(
        Uri.parse("${Api.baseUrl}/auth/login"),
        headers: {"Accept": "application/json"},
        body: {
          "phone": phone,
          "password": pass,
          "fcm_token": fcm,
        },
      );

      print("LOGIN RESPONSE → ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // TODO: store token in secure storage + user info
        final token = data["token"];
        print("🟢 TOKEN FROM LOGIN → $token");
        // token normal
        await storage.write(key: "token", value: token);

        final bioToken = data["biometric_token"];
        await storage.write(key: "biometric_token", value: bioToken);
        // token biometric
        //await storage.write(key: "biometric_token", value: token);

        final savedToken = await storage.read(key: "token");
        print("🔐 TOKEN SAVED IN STORAGE → $savedToken");

        // Vérifions ce que voit vraiment /auth/me AVANT d'aller plus loin
        final meResp = await http.get(
          Uri.parse("${Api.baseUrl}/auth/me"),
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        print("🟣 /auth/me STATUS → ${meResp.statusCode}");
        print("🟣 /auth/me BODY   → ${meResp.body}");


        // context.read<UserProvider>().startInactivityTimer();
// charge user depuis l'API
        await context.read<UserProvider>().loadUserFromApi();

        // start the inactivity timer

// goto dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainLayout(initialIndex: 0)),
        );

        //
      } else {
        // error JSON
        final body = json.decode(response.body);

        _showMessage(body["message"] ?? "Identifiants incorrects.");
      }
    } catch (e) {
      _showMessage("Erreur réseau.");
      print("LOGIN ERROR → $e");
    }

    setState(() => _loading = false);
  }


  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _loginWithBiometrics() async {
    try {
      bool canCheck = await auth.canCheckBiometrics;
      bool supported = await auth.isDeviceSupported();

      if (!canCheck || !supported) {
        _showMessage("Votre appareil ne supporte pas la biométrie.");
        return;
      }

      // 1️⃣ Authentification biométrique
      bool success = await auth.authenticate(
        localizedReason: Platform.isIOS
            ? "Authentifiez-vous avec Face ID / Touch ID"
            : "Authentifiez-vous avec votre empreinte digitale",
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!success) {
        _showMessage("Échec de l'authentification biométrique.");
        return;
      }

      // 2️⃣ Lire le token stocké pour la biométrie
      final bioToken = await storage.read(key: "biometric_token");
      print("Token found $bioToken");

      final resp = await http.post(
        Uri.parse("${Api.baseUrl}/auth/login/biometric"),
        headers: {"Accept": "application/json"},
        body: {
          "biometric_token": bioToken,
        },
      );

      final  newToken = resp.statusCode == 200 ? json.decode(resp.body)["token"] : null;

      await storage.write(key: "token", value: newToken);
      if (newToken == null) {
        _showMessage("Échec de l'authentification biométrique.");
        return;
      }

      print("🔐 TOKEN LOADED FROM STORAGE → $newToken");

      // 3️⃣ Appeler /auth/me pour récupérer l'utilisateur
      final meResp = await http.get(
        Uri.parse("${Api.baseUrl}/auth/me"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $newToken",
        },
      );

      print("🟣 /auth/me STATUS → ${meResp.statusCode}");
      print("🟣 /auth/me BODY   → ${meResp.body}");

      if (meResp.statusCode != 200) {
        _showMessage("Impossible de charger le compte. Reconnectez-vous.");
        return;
      }

      // 4️⃣ Charger le profil dans UserProvider
      await context.read<UserProvider>().loadUserFromApi();

      // 5️⃣ Aller sur Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainLayout(initialIndex: 0)),
      );
    } catch (e) {
      print("BIOMETRIC ERROR → $e");
      _showMessage("Erreur lors de l'authentification biométrique.");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 20),

              // Logo + Title
              /*
              Row(
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "ObpPay",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              */
              Row(
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "ObpPay",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),


              const SizedBox(height: 40),

              const Text(
                "Bienvenue sur ObpPay !",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Connectez-vous pour gérer vos finances.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 30),

              // -------- Phone Field --------
              const Text("Numéro de téléphone",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),

              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: "Ex: 0789123456",
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),

              const SizedBox(height: 25),

              // -------- Password Field --------
              const Text("Mot de passe",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),

              TextField(
                controller: _passwordController,
                obscureText: _hidePassword,
                decoration: InputDecoration(
                  hintText: "Votre mot de passe",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() => _hidePassword = !_hidePassword);
                    },
                    child: Icon(
                      _hidePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ForgetPasswordScreen()),
                  );
                },
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Mot de passe oublié ?",
                    style: TextStyle(
                      color: AppColors.primaryIndigo,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),


              const SizedBox(height: 30),

              // -------- LOGIN BUTTON --------
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryIndigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text(
                    "Se connecter",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // -------- CREATE ACCOUNT --------
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () {
                    // Go to Register
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: AppColors.primaryIndigo, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Créer un compte",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryIndigo,
                    ),
                  ),
                ),
              ),


              // FINGERPRINT AREA
              const SizedBox(height: 30),

              Center(
                child: Column(
                  children: [
                    Text(
                      "Ou connectez-vous avec",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Bouton Biometric Premium
                    InkWell(
                      onTap: _loginWithBiometrics,
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.fingerprint,
                          size: 42,
                          color: AppColors.primaryIndigo,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
