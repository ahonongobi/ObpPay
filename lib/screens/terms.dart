import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Conditions d’utilisation"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          _termsText,
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

const String _termsText = """
Bienvenue dans ObpPay. En utilisant l’application, vous acceptez les conditions d’utilisation suivantes. Veuillez les lire attentivement.

1. Objet du service
ObpPay est une application de portefeuille électronique permettant :
• l’envoi et la réception d’argent,
• la consultation du solde et de l’historique,
• les dépôts et retraits via des canaux définis,
• l’accès à des services financiers additionnels (transferts, achats, marketplace, prêts internes selon éligibilité).

2. Création et sécurité du compte
L’utilisateur doit fournir des informations exactes lors de l’inscription.  
Il est responsable de la confidentialité de son mot de passe et de son téléphone.  
ObpPay se réserve le droit de suspendre un compte en cas de suspicion de fraude, d’usurpation ou d’activité non conforme.

3. Vérification d’identité (KYC)
Certaines fonctionnalités peuvent nécessiter une vérification d’identité (KYC).  
Les documents fournis doivent être authentiques et valides.  
Tout document falsifié entraînera la désactivation du compte.

4. Transactions
• Les transactions sont définitives dès validation.  
• ObpPay ne peut pas annuler un transfert exécuté par l’utilisateur.  
• Des frais peuvent s’appliquer selon les services (définis par l’administrateur).

5. Notifications
L’utilisateur accepte de recevoir des notifications concernant :
• la sécurité du compte,  
• les transactions,  
• les mises à jour importantes.

6. Données personnelles
ObpPay collecte uniquement les données nécessaires au fonctionnement du service.  
Aucune donnée n’est vendue ou partagée sans consentement (voir Politique de Confidentialité).

7. Responsabilités
ObpPay ne peut être tenu responsable :
• d’une mauvaise utilisation de l’application,  
• de pertes causées par un appareil compromis,  
• de pannes liées au fournisseur Internet ou au réseau mobile.

8. Modification des conditions
ObpPay peut mettre à jour les présentes conditions.  
Les utilisateurs seront notifiés en cas de changement majeur.

9. Fermeture du compte
L’utilisateur peut demander la suppression de son compte à tout moment.  
Les données seront conservées uniquement dans les délais légaux.

En utilisant ObpPay, vous acceptez ces conditions.
""";
