import 'package:flutter/material.dart';
import 'package:obppay/screens/otp_screen.dart';
import 'package:obppay/themes/app_colors.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Mot de passe oublié",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 20),

              const Text(
                "Récupérer votre mot de passe",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Entrez votre numéro ObPay ou votre téléphone.\nNous vous enverrons un code de vérification.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Numéro ObPay ou Téléphone",
                  prefixIcon: const Icon(Icons.phone_android),
                  filled: true,
                  fillColor: Colors.grey.shade100,
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
                  onPressed: () {
                    // TODO: Envoyer OTP
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const OtpScreen(purpose: "register")),
                    );

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryIndigo,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Continuer",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Retour",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
