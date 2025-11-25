import 'package:flutter/material.dart';
import 'package:obppay/screens/contact.dart';
import 'package:obppay/screens/edit_profile_screen.dart';
import 'package:obppay/screens/faq.dart';
import 'package:obppay/screens/privacy.dart';
import 'package:obppay/screens/terms.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"),
        centerTitle: true,
      ),

      backgroundColor: theme.scaffoldBackgroundColor,

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          // 🔐 SÉCURITÉ & COMPTE
          _sectionTitle(context, "Sécurité & Compte"),

          ListTile(
            leading: Icon(Icons.lock_outline,
                color: theme.colorScheme.onBackground),
            title: Text("Modifier mot de passe",
                style: TextStyle(color: theme.colorScheme.onBackground)),
            trailing: Icon(Icons.chevron_right,
                color: theme.colorScheme.onBackground),
            onTap: () {
               Navigator.push(
                 context,
                 MaterialPageRoute(
                   builder: (context) => const EditProfileScreen(),
                 ),
               );
            },
          ),

          const SizedBox(height: 20),

          // 🌐 PRÉFÉRENCES
          _sectionTitle(context, "Préférences"),

          ListTile(
            leading:
            Icon(Icons.language, color: theme.colorScheme.onBackground),
            title: Text("Langue",
                style: TextStyle(color: theme.colorScheme.onBackground)),
            subtitle: Text("Français",
                style: TextStyle(color: theme.colorScheme.onBackground)),
            trailing: Icon(Icons.chevron_right,
                color: theme.colorScheme.onBackground),
            onTap: () {},
          ),

          ListTile(
            leading: Icon(Icons.monetization_on_outlined,
                color: theme.colorScheme.onBackground),
            title: Text("Devise affichée",
                style: TextStyle(color: theme.colorScheme.onBackground)),
            subtitle: Text("XOF",
                style: TextStyle(color: theme.colorScheme.onBackground)),
            trailing: Icon(Icons.chevron_right,
                color: theme.colorScheme.onBackground),
            onTap: () {},
          ),

          const SizedBox(height: 20),

          //  APPARENCE
          _sectionTitle(context, "Apparence"),

          SwitchListTile(
            title: Text("Mode sombre",
                style: TextStyle(color: theme.colorScheme.onBackground)),
            secondary:
            Icon(Icons.dark_mode_outlined, color: theme.colorScheme.onBackground),
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(value),
          ),

          const SizedBox(height: 20),

          // ⚖️ LÉGAL
          _sectionTitle(context, "Légal"),

          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TermsScreen()),
              );
            },
            child: ListTile(
              leading: Icon(Icons.article_outlined,
                  color: theme.colorScheme.onBackground),
              title: Text("Conditions d’utilisation",
                  style: TextStyle(color: theme.colorScheme.onBackground)),
              trailing: Icon(Icons.chevron_right,
                  color: theme.colorScheme.onBackground),
            ),
          ),

          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyScreen()),
              );
            },
            child: ListTile(
              leading: Icon(Icons.privacy_tip_outlined,
                  color: theme.colorScheme.onBackground),
              title: Text("Politique de confidentialité",
                  style: TextStyle(color: theme.colorScheme.onBackground)),
              trailing: Icon(Icons.chevron_right,
                  color: theme.colorScheme.onBackground),
            ),
          ),


          const SizedBox(height: 20),

          // 🆘 AIDE
          _sectionTitle(context, "Aide"),

          ListTile(
            leading: Icon(Icons.help_outline, color: theme.colorScheme.onBackground),
            title: Text("FAQ", style: TextStyle(color: theme.colorScheme.onBackground)),
            trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onBackground),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FaqScreen()),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.support_agent, color: theme.colorScheme.onBackground),
            title:
            Text("Contact support", style: TextStyle(color: theme.colorScheme.onBackground)),
            trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onBackground),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactSupportScreen()),
              );
            },
          ),

        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onBackground,
        ),
      ),
    );
  }
}
