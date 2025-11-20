import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:obppay/providers/user_provider.dart';
import 'package:obppay/services/withdraw_service.dart';
import 'package:obppay/themes/app_colors.dart';

class WithdrawRequestScreen extends StatefulWidget {
  const WithdrawRequestScreen({super.key});

  @override
  State<WithdrawRequestScreen> createState() => _WithdrawRequestScreenState();
}

class _WithdrawRequestScreenState extends State<WithdrawRequestScreen> {
  final amountController = TextEditingController();
  final recipientController = TextEditingController();

  String? selectedMethod;
  bool loading = false;

  final methods = [
    {"label": "MTN Mobile Money", "value": "mtn", "icon": Icons.phone_android},
    {"label": "Moov Money", "value": "moov", "icon": Icons.phone_android},

    {"label": "Celtiis", "value": "Celtiis", "icon": Icons.phone_android},
    //{"label": "Virement bancaire", "value": "bank", "icon": Icons.account_balance},
  ];

  Future<void> submitWithdraw() async {
    if (selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez choisir une méthode")),
      );
      return;
    }

    if (amountController.text.trim().isEmpty ||
        double.tryParse(amountController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Montant invalide")),
      );
      return;
    }

    if (recipientController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer le numéro / compte")),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmer le retrait"),
        content: Text(
          "Voulez-vous envoyer une demande de retrait de "
              "${amountController.text} XOF via ${selectedMethod!} ?",
        ),
        actions: [
          TextButton(
            child: const Text("Annuler"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Oui"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => loading = true);

    final token = context.read<UserProvider>().token;

    final result = await WithdrawService.requestWithdraw(
      token: token!,
      amount: double.parse(amountController.text),
      method: selectedMethod!,
      recipient: recipientController.text.trim(),
    );

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result["message"] ?? "Erreur")),
    );

    if (result["success"] == true) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Demande de retrait"),
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.onBackground,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ---- METHODES DE RETRAIT ----
              const Text(
                "Méthode de retrait",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),

              // LISTE DES MÉTHODES
              ...methods.map((m) {
                final value = m["value"] as String;
                final label = m["label"] as String;
                final icon = m["icon"] as IconData;

                final isSelected = selectedMethod == value;

                return GestureDetector(
                  onTap: () => setState(() => selectedMethod = value),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryIndigo
                            : theme.dividerColor,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          color: isSelected
                              ? AppColors.primaryIndigo
                              : theme.iconTheme.color,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // ---- MONTANT ----
              const Text(
                "Montant",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Ex : 20000",
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ---- NUMÉRO BÉNÉFICIAIRE ----
              const Text(
                "Numéro / compte bénéficiaire",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: recipientController,
                decoration: InputDecoration(
                  hintText: "Ex : 61020304",
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ---- BUTTON ----
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: loading ? null : submitWithdraw,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryIndigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Envoyer la demande",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }
}
