import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Politique de confidentialité"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          _privacyText,
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: theme.colorScheme.onBackground,
          ),
        ),
      ),
    );
  }
}

const String _privacyText = """
Cette politique explique comment ObpPay collecte, utilise et protège vos données personnelles.

1. Données collectées
Nous collectons uniquement les informations nécessaires à la création et l’utilisation du service :
• numéro de téléphone,  
• identifiants ObPay,  
• informations KYC (si fournies),  
• historique des transactions,  
• informations de sécurité (fcm_token pour notifications).  

Aucune donnée bancaire sensible n’est stockée dans l’application.

2. Utilisation des données
Les données servent à :
• authentifier l’utilisateur,  
• sécuriser le compte et détecter les fraudes,  
• envoyer des notifications (transactions, sécurité…),  
• améliorer les services ObpPay.

3. Stockage et sécurité
Vos données sont stockées de manière sécurisée.  
Nous utilisons des technologies modernes pour protéger vos informations contre :
• l’accès non autorisé,  
• la modification,  
• la perte ou le vol.

4. Partage des données
ObpPay ne vend pas vos données.  
Elles peuvent être partagées uniquement dans les cas suivants :
• obligation légale (police, autorité judiciaire),  
• vérification d'identité (si KYC).

5. Permissions de l’appareil
• Notifications : pour vous informer des transactions & sécurité.  
• Appareil photo : uniquement pour KYC.  
• Biométrie : pour un login plus sécurisé (nécessite votre accord).

6. Conservation des données
Les données sont conservées seulement pour la durée légale nécessaire, puis supprimées ou anonymisées.

7. Vos droits
Vous pouvez :
• demander la suppression de votre compte,  
• corriger vos informations,  
• désactiver la biométrie,  
• contacter le support pour toute question relative à vos données.

8. Mise à jour
Cette politique peut être modifiée en cas de changement technique ou légal.  
Vous serez informé des mises à jour importantes.

En utilisant ObpPay, vous acceptez cette politique de confidentialité.
""";
