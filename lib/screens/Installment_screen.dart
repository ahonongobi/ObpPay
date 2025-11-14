import 'package:flutter/material.dart';
import 'package:obppay/themes/app_colors.dart';

class InstallmentScreen extends StatelessWidget {
  final String productName;
  final String productPrice;

  const InstallmentScreen({
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
        elevation: 0.3,
        foregroundColor: Colors.black,
        title: const Text(
          "Paiement en tranches",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Infos produit
            Text(
              productName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Prix total : $productPrice",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryIndigo,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Choisissez votre option de paiement :",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 20),

            // 3 tranches
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                leading: const Icon(Icons.timer, size: 28),
                title: const Text("Payer en 3 tranches"),
                subtitle: const Text("Répartition du paiement sur 3 mois"),
                trailing:
                const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {
                  // TODO: logique pour paiement en 3 tranches
                  // par ex: afficher un écran de résumé ou de confirmation
                },
              ),
            ),

            const SizedBox(height: 10),

            // 4 tranches
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                leading: const Icon(Icons.schedule, size: 28),
                title: const Text("Payer en 4 tranches"),
                subtitle: const Text("Répartition du paiement sur 4 mois"),
                trailing:
                const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {
                  // TODO: logique pour paiement en 4 tranches
                },
              ),
            ),

            const Spacer(),

            // Bouton retour simple
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primaryIndigo, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Retour",
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
