import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:obppay/screens/Installment_screen.dart';
import 'package:obppay/services/api.dart';
import 'package:obppay/themes/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/user_provider.dart';
import '../services/local_notif.dart';


class PaymentOptionsScreen extends StatelessWidget {

  final int id;
  final String productName;
  final String productPrice;

  const PaymentOptionsScreen({
    super.key,
    required this.id,
    required this.productName,
    required this.productPrice,
  });

  Future<void> confirmAndPayNow(BuildContext context) async {
    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Confirmer le paiement",
            style: TextStyle(
              color: theme.colorScheme.onBackground,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Le montant total de ${productPrice} sera débité de votre compte ObPay.\nVoulez-vous continuer ?",
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "Annuler",
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryIndigo,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Oui"),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await payNow(context);
    }
  }
  Future<void> payNow(BuildContext context) async {
    final token = context.read<UserProvider>().token;

    final res = await http.post(
      Uri.parse("${Api.baseUrl}/market/pay-now"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
      body: {
        "product_id": id.toString(),
      },
    );

    final data = jsonDecode(res.body);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(data["message"] ?? "Paiement effectué"),
      ),
    );

    await LocalNotif.show(
      title: "Paiement effectué",
      body: "Vous avez acheté $productName pour $productPrice.",
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: theme.colorScheme.onBackground,
        centerTitle: true,
        title: Text(
          "Mode de paiement",
          style: TextStyle(
            color: theme.colorScheme.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // --- PRODUCT NAME ---
            Text(
              "Produit : $productName",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),

            const SizedBox(height: 6),

            // --- PRICE ---
            Text(
              "Prix : $productPrice",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryIndigo,
              ),
            ),

            const SizedBox(height: 30),

            // --- OPTIONS TITLE ---
            Text(
              "Choisissez une option :",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onBackground,
              ),
            ),

            const SizedBox(height: 20),

            // ---------------------------
            // OPTION 1 — PAYER COMPLET
            // ---------------------------
            Card(
              color: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: Icon(
                  Icons.payment,
                  size: 28,
                  color: theme.colorScheme.onSurface,
                ),
                title: Text(
                  "Payer maintenant",
                  style: TextStyle(color: theme.colorScheme.onBackground),
                ),
                subtitle: Text(
                  "Débiter le montant total du compte ObPay",
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurface,
                ),
                onTap: () {
                  // 👉 TODO backend: Vérifier solde + paiement direct
                  confirmAndPayNow(context);
                },
              ),
            ),

            const SizedBox(height: 16),

            // ---------------------------
            // OPTION 2 — TRANCHES
            // ---------------------------
            Card(
              color: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: Icon(
                  Icons.schedule,
                  size: 28,
                  color: theme.colorScheme.onSurface,
                ),
                title: Text(
                  "Payer en tranches",
                  style: TextStyle(color: theme.colorScheme.onBackground),
                ),
                subtitle: Text(
                  "Répartir le paiement sur 3, 4 mois ou plus",
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurface,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InstallmentScreen(
                        productId:  id,
                        productName: productName,
                        productPrice: productPrice,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
