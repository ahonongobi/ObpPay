import 'package:flutter/material.dart';
import 'package:obppay/themes/app_colors.dart';
import 'package:obppay/screens/login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:obppay/services/api.dart';

class NewPasswordScreen extends StatefulWidget {
  final String phone;
  final String otp;

  const NewPasswordScreen({
    super.key,
    required this.phone,
    required this.otp,
  });

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  bool showNew = false;
  bool showConfirm = false;
  bool loading = false;

  Future<void> _submit() async {
    final pass = newPassController.text.trim();
    final confirm = confirmPassController.text.trim();

    if (pass.isEmpty || confirm.isEmpty) {
      return _error("Veuillez remplir tous les champs.");
    }

    if (pass.length < 6) {
      return _error("Le mot de passe doit contenir au moins 6 caractères.");
    }

    if (pass != confirm) {
      return _error("Les mots de passe ne correspondent pas.");
    }

    setState(() => loading = true);

    try {
      final response = await http.post(
        Uri.parse("${Api.baseUrl}/auth/reset-password"),
        body: {
          "phone": widget.phone,
          "otp": widget.otp,
          "password": pass,
        },
      );

      final body = json.decode(response.body);
      print("RESET PASSWORD → ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mot de passe mis à jour !")),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      } else {
        _error(body["message"] ?? "Erreur");
      }
    } catch (e) {
      _error("Erreur réseau.");
      print("RESET ERROR → $e");
    }

    setState(() => loading = false);
  }

  void _error(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: theme.colorScheme.onBackground,
        title: Text(
          "Nouveau mot de passe",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onBackground,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 10),

            Text(
              "Réinitialisation",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Définissez un nouveau mot de passe sécurisé\npour votre compte ObPay.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 30),

            // -------- NEW PASSWORD --------
            TextField(
              controller: newPassController,
              obscureText: !showNew,
              decoration: InputDecoration(
                labelText: "Nouveau mot de passe",
                prefixIcon: Icon(Icons.lock, color: theme.iconTheme.color),
                suffixIcon: IconButton(
                  icon: Icon(
                    showNew ? Icons.visibility : Icons.visibility_off,
                    color: theme.iconTheme.color,
                  ),
                  onPressed: () {
                    setState(() => showNew = !showNew);
                  },
                ),
                filled: true,
                fillColor: theme.cardColor.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // -------- CONFIRM PASSWORD --------
            TextField(
              controller: confirmPassController,
              obscureText: !showConfirm,
              decoration: InputDecoration(
                labelText: "Confirmer le mot de passe",
                prefixIcon: Icon(Icons.lock_outline, color: theme.iconTheme.color),
                suffixIcon: IconButton(
                  icon: Icon(
                    showConfirm ? Icons.visibility : Icons.visibility_off,
                    color: theme.iconTheme.color,
                  ),
                  onPressed: () {
                    setState(() => showConfirm = !showConfirm);
                  },
                ),
                filled: true,
                fillColor: theme.cardColor.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // -------- BUTTON --------
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryIndigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Enregistrer",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
