import 'package:flutter/material.dart';
import 'package:obppay/screens/Notification_Screen.dart';
import 'package:obppay/screens/kycverification_screen.dart';
import 'package:obppay/screens/login_screen.dart';
import 'package:obppay/screens/setting_screen.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../themes/app_colors.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<UserProvider>().refreshUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final provider = context.watch<UserProvider>();
    final theme = Theme.of(context);

    final isEligible = provider.loanEligibility == 1;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0.4,
        centerTitle: true,
        title: Text(
          "Profil",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onBackground,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // ===== PROFILE CARD =====
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundImage: user.avatarUrl != null
                            ? NetworkImage(user.avatarUrl!)
                            : const AssetImage("assets/images/logo.png") as ImageProvider,
                      ),

                      // EDIT BUTTON
                      GestureDetector(
                        onTap: () async {
                          final provider = context.read<UserProvider>();
                          await provider.pickAndUploadProfileImage(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryIndigo,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, size: 18, color: Colors.white),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  _infoRow(
                    context,
                    Icons.person_outline,
                    "Nom complet",
                    user.fullName,
                  ),

                  _infoRow(
                    context,
                    Icons.wallet,
                    "ID ObPay",
                    user.obpayId,
                  ),

                  _infoRow(
                    context,
                    Icons.phone,
                    "Téléphone",
                    user.phone,
                  ),

                  // ===== ELIGIBILITY BADGE =====
                  Row(
                    children: [
                      Icon(Icons.verified,
                          color: isEligible ? Colors.green : Colors.red),
                      const SizedBox(width: 10),
                      Text(
                        isEligible
                            ? "Éligible (Points : ${user.score})"
                            : "Non Éligible (Points : ${user.score})",
                        style: TextStyle(
                          color: isEligible ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===== SETTINGS SECTION =====
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.edit, color: theme.colorScheme.onBackground),
                    title: Text(
                      "Modifier le profil",
                      style: TextStyle(color: theme.colorScheme.onBackground),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                      );
                    },
                  ),

                  Divider(color: theme.dividerColor),

                  ListTile(
                    leading:
                    Icon(Icons.settings_outlined, color: theme.colorScheme.onBackground),
                    title: Text(
                      "Paramètres",
                      style: TextStyle(color: theme.colorScheme.onBackground),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading:
                    Icon(Icons.verified_user, color: theme.colorScheme.onBackground),
                    title: Text(
                      "KYC & Vérification",
                      style: TextStyle(color: theme.colorScheme.onBackground),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const KycVerificationScreen()),
                      );
                    },
                  ),

                  // NotificationScreen
                  ListTile(
                    leading:
                    Icon(Icons.notifications, color: theme.colorScheme.onBackground),
                    title: Text(
                      "Notifications",
                      style: TextStyle(color: theme.colorScheme.onBackground),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationScreen()),
                      );
                    },
                  ),

                  Divider(color: theme.dividerColor),

                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      "Se déconnecter",
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () async {
                      await context.read<UserProvider>().logout(context);

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =======================
  // INFO ROW FIXED + THEME
  // =======================
  Widget _infoRow(
      BuildContext context,
      IconData icon,
      String title,
      String value,
      ) {
    final theme = Theme.of(context);

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
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                Divider(
                  height: 20,
                  color: theme.dividerColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
