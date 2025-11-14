import 'package:flutter/material.dart';
import 'package:obppay/screens/ForgetPasswordScreen.dart';
import 'package:obppay/screens/main_layout.dart';
import 'package:obppay/screens/regsiter_screen.dart';
import 'package:obppay/themes/app_colors.dart';
import 'dashboard_screen.dart';

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

  void _login() async {
    final phone = _phoneController.text.trim();
    final pass = _passwordController.text.trim();

    if (phone.isEmpty || pass.isEmpty) {
      _showMessage("Veuillez remplir tous les champs.");
      return;
    }

    setState(() => _loading = true);

    await Future.delayed(const Duration(seconds: 1)); // simulation API

    if (phone == fakePhone && pass == fakePassword) {
      // SUCCESS
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainLayout(initialIndex: 0)),
      );
    } else {
      _showMessage("Numéro ou mot de passe incorrect.");
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
              Row(
                children: const [
                  Icon(Icons.account_balance_wallet,
                      size: 40, color: AppColors.primaryIndigo),
                  SizedBox(width: 8),
                  Text(
                    "ObPay",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              const Text(
                "Bienvenue sur ObPay !",
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
            ],
          ),
        ),
      ),
    );
  }
}
