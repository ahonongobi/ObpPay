import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../themes/app_colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController fullNameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController emailCtrl;

  // Password controllers
  final currentPasswordCtrl = TextEditingController();
  final newPasswordCtrl = TextEditingController();

  bool isSaving = false;
  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;

    fullNameCtrl = TextEditingController(text: user.fullName);
    phoneCtrl = TextEditingController(text: user.phone);
    emailCtrl = TextEditingController(text: user.email ?? "");
  }
  bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    return regex.hasMatch(email);
  }

  @override
  void dispose() {
    fullNameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    currentPasswordCtrl.dispose();
    newPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final userProvider = context.read<UserProvider>();
    final token = userProvider.token;

    final name  = fullNameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    final email = emailCtrl.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nom et téléphone sont obligatoires."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (email.isNotEmpty && !isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email invalide."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      // ---- 1) Update profil ----
      final response = await http.put(
        Uri.parse("${Api.baseUrl}/auth/profile"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": name,
          "phone": phone,
          "email": email.isEmpty ? null : email,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Mettre à jour le provider localement
        userProvider.updateUserProfile(
          fullName: name,
          phone: phone,
          email: email.isEmpty ? null : email,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil mis à jour avec succès ✅"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "Erreur lors de la mise à jour."),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => isSaving = false);
        return;
      }

      // ---- 2) Changer mot de passe si rempli ----
      if (currentPasswordCtrl.text.isNotEmpty &&
          newPasswordCtrl.text.isNotEmpty) {
        final pwdResp = await http.post(
          Uri.parse("${Api.baseUrl}/auth/change-password"),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "current_password": currentPasswordCtrl.text,
            "new_password": newPasswordCtrl.text,
          }),
        );

        final pwdData = jsonDecode(pwdResp.body);

        if (pwdResp.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Mot de passe modifié avec succès 🔐"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
              Text(pwdData["message"] ?? "Erreur lors du changement de mot de passe."),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => isSaving = false);
          return;
        }
      }

      setState(() => isSaving = false);
      Navigator.pop(context);

    } catch (e) {
      setState(() => isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Impossible de contacter le serveur."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {

    final user = context.watch<UserProvider>().user;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier le profil"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ---------- FULL NAME ----------
            TextField(
              controller: fullNameCtrl,
              decoration: const InputDecoration(
                labelText: "Nom complet",
              ),
            ),
            const SizedBox(height: 20),

            // ---------- PHONE ----------
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Téléphone",
              ),
            ),
            const SizedBox(height: 20),

            // ---------- EMAIL ----------
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
              ),
            ),

            const SizedBox(height: 35),
            const Divider(height: 30),

            // =======================================================
            //   SECTION CHANGER MOT DE PASSE
            // =======================================================

            const Text(
              "Modifier le mot de passe",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: currentPasswordCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Mot de passe actuel",
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: newPasswordCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Nouveau mot de passe",
              ),
            ),

            const SizedBox(height: 40),

            // ---------- SAVE BUTTON ----------
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryIndigo,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: isSaving ? null : _saveProfile,
            child: isSaving
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Text(
              "Enregistrer",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
          ],
        ),
      ),
    );
  }
}
