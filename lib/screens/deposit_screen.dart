import 'package:flutter/material.dart';
import 'package:obppay/themes/app_colors.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  int selectedMethod = 1; // 1 = Mobile Money, 2 = Moov, 3 = Celtis

  final TextEditingController mmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Méthode de Paiement",
            style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0.4,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                "Sélectionnez votre méthode de paiement préférée.",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 20),

              // ===== 1. MOBILE MONEY =====
              _paymentMethodCard(
                value: 1,
                title: "Mobile Money",
                subtitle: "Paiement sécurisé via votre compte Mobile Money.",
                child: selectedMethod == 1
                    ? Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: TextField(
                    controller: mmController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: "Votre numéro Mobile Money (ex: 07...)",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                )
                    : null,
              ),

              const SizedBox(height: 18),

              // ===== 2. MOOV =====
              _paymentMethodCard(
                value: 2,
                title: "Moov Money",
                subtitle: "Utilisez Moov Money pour un paiement rapide.",
              ),

              const SizedBox(height: 18),

              // ===== 3. CELTIS =====
              _paymentMethodCard(
                value: 3,
                title: "Celtis",
                subtitle: "Paiement via le service bancaire Celtis.",
              ),

              const SizedBox(height: 40),

              // ===== BUTTON =====
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryIndigo,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Confirmer le paiement",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

    );
  }

  // ======================== WIDGET CARD ========================

  Widget _paymentMethodCard({
    required int value,
    required String title,
    required String subtitle,
    Widget? child,
  }) {
    final bool isSelected = selectedMethod == value;

    return GestureDetector(
      onTap: () {
        setState(() => selectedMethod = value);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryIndigo : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Radio personnalisé
                Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryIndigo
                          : Colors.black45,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                    child: Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        color: AppColors.primaryIndigo,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                      : null,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),

            if (child != null) child,
          ],
        ),
      ),
    );
  }
}
