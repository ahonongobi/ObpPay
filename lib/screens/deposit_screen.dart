import 'package:flutter/material.dart';
import 'package:obppay/providers/user_provider.dart';
import 'package:obppay/services/payment_manager.dart';
import 'package:obppay/themes/app_colors.dart';
import 'package:obppay/services/momo_service.dart';
import 'package:provider/provider.dart';


class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  int? selectedMethod; // Au début : rien sélectionné

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Méthode de Paiement",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0.4,
      ),

      backgroundColor: theme.scaffoldBackgroundColor,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "Sélectionnez votre méthode de paiement.",
              style: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.onBackground,
              ),
            ),

            const SizedBox(height: 20),

            // ===== PAYMENT OPTIONS =====
            _paymentMethodCard(
              context: context,
              value: 1,
              title: "MTN Mobile Money",
              subtitle: "Paiement sécurisé via MoMo.",
            ),

            const SizedBox(height: 14),

            _paymentMethodCard(
              context: context,
              value: 2,
              title: "Moov Money",
              subtitle: "Paiement rapide via Moov.",
            ),

            const SizedBox(height: 14),

            _paymentMethodCard(
              context: context,
              value: 3,
              title: "Celtis",
              subtitle: "Paiement par Celtis bancaire.",
            ),

            const SizedBox(height: 10),

            // ===== FORM FIELDS (show only if method selected) =====
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.fastOutSlowIn,
              child: selectedMethod == null
                  ? const SizedBox.shrink()
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),

                  // PHONE INPUT
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Numéro Mobile Money",
                      hintText: "Ex: 07xxxxxx",
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // AMOUNT INPUT
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Montant",
                      hintText: "Ex: 2000",
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final phone = phoneController.text.trim();
                        final amount = amountController.text.trim();

                        if (phone.isEmpty || amount.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Veuillez remplir tous les champs")),
                          );
                          return;
                        }

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(child: CircularProgressIndicator()),
                        );

                        final provider = context.read<UserProvider>();

                        final result = await PaymentManager.process(
                          method: selectedMethod!,
                          phone: phone,
                          amount: amount,
                          token: provider.token!,
                        );

                        Navigator.pop(context); // close loader

                        // ============= DEBUG PRINTS =============
                        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
                        print("🔵 API RAW RESULT:");
                        print(result);
                        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

                        // ============= HANDLE API CRASH =============
                        if (result["success"] != true) {
                          print("🔴 DEBUG — PAYMENT FAILED BEFORE MO-MO STATUS");
                          print("Erreur API : ${result['error']}");

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Erreur API : ${result['error']}"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // ============= REAL MOMO STATUS =============
                        dynamic statusObject = result["status"];

                        String momoStatus;
                        String? momoReason;

                        if (statusObject is Map) {
                          momoStatus = statusObject["status"] ?? "UNKNOWN";
                          momoReason = statusObject["reason"];
                        } else if (statusObject is String) {
                          momoStatus = statusObject;
                          momoReason = null;
                        } else {
                          momoStatus = "UNKNOWN";
                          momoReason = null;
                        }

                        print("🔵 MOMO STATUS : $momoStatus");
                        print("🔵 MOMO REASON : ${momoReason ?? 'None'}");

                        // ============= SUCCESS CASE =============
                        if (result["credited"] == true) {
                          // 🔄 Refresh user balance
                          await context.read<UserProvider>().refreshUser();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Dépôt réussi ! Nouveau solde mis à jour."),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          print("🔴 DEBUG — PAYMENT NOT CREDITED");
                        }

                        if (momoStatus == "SUCCESSFUL") {
                          print("🟢 PAYMENT SUCCESSFUL");

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Paiement réussi ! Votre compte sera crédité."),
                              backgroundColor: Colors.green,
                            ),
                          );

                        } else {
                          // ============= FAILED CASE =============
                          print("🔴 PAYMENT FAILED — $momoStatus ($momoReason)");

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Paiement échoué : ${momoReason ?? 'Erreur inconnue'}"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },


                        style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text("Confirmer le paiement"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================== WIDGET CARD ========================

  Widget _paymentMethodCard({
    required BuildContext context,
    required int value,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final bool isSelected = selectedMethod == value;

    return GestureDetector(
      onTap: () => setState(() => selectedMethod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryIndigo.withOpacity(0.08)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryIndigo : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),

        child: Row(
          children: [
            // Radio circle
            Container(
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryIndigo
                      : theme.colorScheme.onSurface.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  height: 12,
                  width: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryIndigo,
                    shape: BoxShape.circle,
                  ),
                ),
              )
                  : null,
            ),

            const SizedBox(width: 14),

            // Titles
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
