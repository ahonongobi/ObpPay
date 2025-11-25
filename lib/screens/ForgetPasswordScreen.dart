import 'package:flutter/material.dart';
import 'package:obppay/screens/otp_screen.dart';
import 'package:provider/provider.dart';
import 'package:obppay/themes/app_colors.dart';
import '../providers/theme_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:obppay/services/api.dart';


class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // 🔥 Supporte dark mode automatiquement

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Mot de passe oublié"),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "Récupérer votre mot de passe",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Entrez votre numéro de téléphone. "
                    "Nous vous enverrons un code de vérification.",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Téléphone",
                  prefixIcon: const Icon(Icons.phone_android),
                  filled: true,
                  fillColor: theme.cardColor.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final phone = phoneController.text.trim();

                    if (phone.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Veuillez entrer un numéro."),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    // 🔥 Appel API forgot-password
                    final response = await http.post(
                      Uri.parse("${Api.baseUrl}/auth/forgot-password"),
                      headers: {
                        "Accept": "application/json",
                      },
                      body: {"phone": phone},
                    );

                    print("FORGOT RESPONSE → ${response.body}");

                    if (response.statusCode == 200) {
                      // 🎉 Naviguer vers OTP screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OtpScreen(
                            purpose: "reset",
                            phone: phone,
                          ),
                        ),
                      );
                    } else {
                      final body = json.decode(response.body);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(body["message"] ?? "Erreur"),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryIndigo,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Envoyer le code",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),


              const SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Retour",
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
