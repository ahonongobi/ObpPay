import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../themes/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController fullNameCtrl;
  late TextEditingController phoneCtrl;

  @override
  void initState() {
    final user = context.read<UserProvider>().user;
    fullNameCtrl = TextEditingController(text: user.fullName);
    phoneCtrl = TextEditingController(text: user.phone);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier le profil"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: fullNameCtrl,
              decoration: const InputDecoration(labelText: "Nom complet"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: "Téléphone"),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryIndigo,
                ),
                onPressed: () {
                  context.read<UserProvider>().updateUser(
                    fullNameCtrl.text,
                    phoneCtrl.text,
                  );
                  Navigator.pop(context);
                },
                child: const Text("Enregistrer"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
