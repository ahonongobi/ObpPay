import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("FAQ"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _FaqItem(
            question: "Comment créer un compte ObpPay ?",
            answer:
            "Téléchargez l’application, entrez votre numéro, validez l’OTP et renseignez vos informations.",
          ),
          _FaqItem(
            question: "Comment envoyer de l’argent ?",
            answer:
            "Allez dans l’onglet Transfert, entrez le numéro du destinataire et le montant.",
          ),
          _FaqItem(
            question: "Comment déposer ou retirer des fonds ?",
            answer:
            "Utilisez un agent physique ou les moyens de dépôt disponibles dans l’application.",
          ),
          _FaqItem(
            question: "Est-ce que mes informations sont sécurisées ?",
            answer:
            "Oui. ObpPay utilise un chiffrement avancé et la biométrie pour protéger votre compte.",
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        iconColor: theme.colorScheme.primary,
        collapsedIconColor: theme.colorScheme.onSurface,
        title: Text(
          question,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onBackground,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          )
        ],
      ),
    );
  }
}
