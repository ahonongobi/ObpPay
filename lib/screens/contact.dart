import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:obppay/providers/user_provider.dart';
import 'package:obppay/services/api.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  void _openWhatsApp() async {
    final uri = Uri.parse("https://wa.me/22900000000?text=Bonjour%20ObpPay");
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _sendEmail() async {
    final uri = Uri.parse(
        "mailto:support@obppay.com?subject=Support%20ObpPay&body=Bonjour%2C");
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Support")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: theme.colorScheme.surface,
            child: ListTile(
              leading: const Icon(Icons.chat_bubble, color: Colors.green),
              title: const Text("Contacter via WhatsApp"),
              subtitle: const Text("Réponse rapide"),
              onTap: _openWhatsApp,
            ),
          ),
          Card(
            color: theme.colorScheme.surface,
            child: ListTile(
              leading: Icon(Icons.email_outlined,
                  color: theme.colorScheme.onBackground),
              title: const Text("Envoyer un email"),
              subtitle: const Text("support@obppay.com"),
              onTap: _sendEmail,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Envoyer un message",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 10),
          _SupportForm(),
        ],
      ),
    );
  }
}

class _SupportForm extends StatefulWidget {
  const _SupportForm();

  @override
  State<_SupportForm> createState() => _SupportFormState();
}

class _SupportFormState extends State<_SupportForm> {
  final TextEditingController msgController = TextEditingController();
  bool sending = false;

  Future<void> sendMessage() async {
    final text = msgController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez écrire un message.")),
      );
      return;
    }

    setState(() => sending = true);

    try {
      final response = await http.post(
        Uri.parse("${Api.baseUrl}/support/message"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${context.read<UserProvider>().token}",
        },
        body: {
          "message": text,
        },
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        msgController.clear();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Message envoyé ✔")));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(body["message"] ?? "Erreur")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur réseau : $e")));
    }

    setState(() => sending = false);
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        TextField(
          controller: msgController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "Décrivez votre problème...",
            filled: true,
            fillColor: theme.cardColor.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: sending ? null : sendMessage,
            child: sending
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Envoyer"),
          ),
        ),
      ],
    );
  }
}
