import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../themes/app_colors.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.4,
        centerTitle: true,
        title: const Text("Profil",
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // ------- INFO CARD -------
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundImage: AssetImage("assets/images/logo.png"),
                  ),

                  const SizedBox(height: 20),

                  _infoRow(Icons.person_outline, "Nom complet", user.fullName),
                  _infoRow(Icons.wallet, "ID ObPay", user.obpayId),
                  _infoRow(Icons.phone, "Téléphone", user.phone),

                  const SizedBox(height: 6),

                  // -------- BADGE ELIGIBILITÉ --------
                  Row(
                    children: [
                      Icon(Icons.verified,
                          color: user.isEligible ? Colors.green : Colors.red),
                      const SizedBox(width: 10),
                      Text(
                        user.isEligible
                            ? "Éligible (Points : ${user.points})"
                            : "Non Éligible (Points : ${user.points})",
                        style: TextStyle(
                          color: user.isEligible ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ------- Settings -------
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text("Modifier le profil"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text("Paramètres"),
                    onTap: () {},
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text("Se déconnecter",
                        style: TextStyle(color: Colors.red)),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryIndigo),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const Divider(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
