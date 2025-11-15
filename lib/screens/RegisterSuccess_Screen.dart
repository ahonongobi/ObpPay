import 'dart:async';
import 'package:flutter/material.dart';
import 'package:obppay/screens/login_screen.dart';
import 'package:obppay/themes/app_colors.dart';

class RegisterSuccessScreen extends StatefulWidget {
  final String obpId;

  const RegisterSuccessScreen({super.key, required this.obpId});

  @override
  State<RegisterSuccessScreen> createState() => _RegisterSuccessScreenState();
}

class _RegisterSuccessScreenState extends State<RegisterSuccessScreen> {

  @override
  void initState() {
    super.initState();

    // Auto redirect after 4 seconds
    Timer(const Duration(seconds: 10), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Circle animated success icon
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.primaryIndigo.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 90,
                  color: AppColors.primaryIndigo,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Compte créé avec succès !",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "Votre identifiant ObPay est :",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                widget.obpId,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryIndigo,
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                "Redirection automatique...",
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 25),

              // Manual login button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryIndigo, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Se connecter maintenant",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryIndigo,
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
