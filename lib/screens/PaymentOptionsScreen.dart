import 'package:flutter/material.dart';
import 'package:obppay/screens/Installment_screen.dart';
import 'package:obppay/themes/app_colors.dart';

class PaymentOptionsScreen extends StatelessWidget {
  final String productName;
  final String productPrice;

  const PaymentOptionsScreen({
    super.key,
    required this.productName,
    required this.productPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text("Mode de paiement"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "Produit : $productName",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              "Prix : $productPrice",
              style: TextStyle(
                  fontSize: 18,
                  color: AppColors.primaryIndigo,
                  fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 30),

            const Text(
              "Choisissez une option :",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 20),

            // PAYER COMPLÈTEMENT
            ListTile(
              leading: const Icon(Icons.payment, size: 28),
              title: const Text("Payer maintenant"),
              subtitle: const Text("Débiter le montant total du compte ObPay"),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                // TODO: Vérifier le solde + débiter + confirmer achat
              },
            ),

            const SizedBox(height: 10),

            // PAYER EN TRANCHES
            ListTile(
              leading: const Icon(Icons.schedule, size: 28),
              title: const Text("Payer en tranches"),
              subtitle: const Text("Répartir le paiement sur 3 ou 4 mois"),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                // TODO: ouvrir la page choix tranche
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InstallmentScreen(
                      productName: productName,
                      productPrice: productPrice,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
