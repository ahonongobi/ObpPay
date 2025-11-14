import 'package:flutter/material.dart';
import 'package:obppay/themes/app_colors.dart';
import 'login_screen.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  bool showNew = false;
  bool showConfirm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          "Nouveau mot de passe",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 10),

            const Text(
              "Réinitialisation",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Définissez un nouveau mot de passe sécurisé\npour votre compte ObPay.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 30),

            // -------- NEW PASSWORD --------
            TextField(
              controller: newPassController,
              obscureText: !showNew,
              decoration: InputDecoration(
                labelText: "Nouveau mot de passe",
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                      showNew ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() => showNew = !showNew);
                  },
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
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
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                      showConfirm ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() => showConfirm = !showConfirm);
                  },
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
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
                onPressed: () {
                  final pass = newPassController.text.trim();
                  final confirm = confirmPassController.text.trim();

                  if (pass.isEmpty || confirm.isEmpty) {
                    _error("Veuillez remplir tous les champs.");
                    return;
                  }
                  if (pass.length < 6) {
                    _error("Le mot de passe doit contenir au moins 6 caractères.");
                    return;
                  }
                  if (pass != confirm) {
                    _error("Les mots de passe ne correspondent pas.");
                    return;
                  }

                  // 🎉 Success
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryIndigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Enregistrer",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- ERROR SNACKBAR ----------------
  void _error(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
