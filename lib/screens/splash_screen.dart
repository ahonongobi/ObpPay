import 'package:flutter/material.dart';
import 'package:obppay/screens/login_screen.dart';
import 'dart:async';

import 'package:obppay/themes/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    // Navigate to next screen after animation
    Timer(const Duration(seconds: 3), () {
      // TODO: redirect to LoginScreen
       Navigator.pushReplacement(context,
         MaterialPageRoute(builder: (_) => const LoginScreen()),
       );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryIndigo,

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          const Spacer(),

          // --- LOGO CAURIS ---
          Center(
            child: Image.asset(
              "assets/images/logo.png",   // chemin du logo cauris
              width: 150,
              height: 150,
              fit: BoxFit.contain,
             // color: Colors.white,         // rend le cauris blanc stylé
            ),
          ),

          const Spacer(),

          // --- PROGRESS BAR ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _controller.value,
                    minHeight: 5,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
