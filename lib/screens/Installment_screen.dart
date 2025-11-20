import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:obppay/services/api.dart';
import 'package:obppay/themes/app_colors.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../services/local_notif.dart';

class InstallmentScreen extends StatefulWidget {
  final int productId;
  final String productName;
  final String productPrice;

  const InstallmentScreen({
    super.key,
    required this.productId,
    required this.productName,
    required this.productPrice,
  });

  @override
  State<InstallmentScreen> createState() => _InstallmentScreenState();
}

class _InstallmentScreenState extends State<InstallmentScreen> {
  bool loading = true;
  List plans = [];

  @override
  void initState() {
    super.initState();
    loadPlans();
  }


  Future<void> loadPlans() async {
    final token = context.read<UserProvider>().token;

    print("🔐 TOKEN → $token");
    print("📦 PRODUCT ID → ${widget.productId}");

    final url = "${Api.baseUrl}/products/${widget.productId}/installments";
    print("🌍 URL → $url");

    final res = await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    print("📥 RAW RESPONSE → ${res.body}");

    final decoded = jsonDecode(res.body);

    if (decoded is List) {
      setState(() {
        plans = decoded;
        loading = false;
      });
    } else {
      setState(() {
        plans = [];
        loading = false;
      });
    }
  }

  Future<void> confirmAndStart(int planId, String monthlyAmount) async {
    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Confirmer le paiement",
            style: TextStyle(color: theme.colorScheme.onBackground),
          ),
          content: Text(
            "La première tranche de $monthlyAmount XOF sera débitée de votre compte ObPay.\n\nVoulez-vous continuer ?",
            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8)),
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
      startInstallment(planId);
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Paiement en tranches"),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),

      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: EdgeInsets.all(20),
        itemCount: plans.length,
        itemBuilder: (_, i) {
          final p = plans[i];

          return Card(
            color: theme.colorScheme.surface,
            child: ListTile(
              title: Text(
                "${p['months']} mois",
                style: TextStyle(color: theme.colorScheme.onBackground),
              ),
              subtitle: Text(
                "Montant mensuel : ${p['monthly_amount']} XOF",
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Start installment
                //startInstallment(p['id']);
                confirmAndStart(p['id'], p['monthly_amount'].toString());

              },
            ),
          );
        },
      ),
    );
  }

  Future<void> startInstallment(int planId) async {
    final token = context.read<UserProvider>().token;

    final res = await http.post(
      Uri.parse("${Api.baseUrl}/market/installment/start"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
      body: {
        "product_id": widget.productId.toString(),
        "plan_id": planId.toString(),
      },
    );

    final data = jsonDecode(res.body);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data["message"] ?? "Tranche démarrée")),
    );

    await LocalNotif.show(
      title: "Tranche démarrée",
      body:
          "Vous avez commencé un paiement en tranches pour ${widget.productName}.",
    );
  }
}

