import 'package:flutter/material.dart';
import 'package:obppay/screens/ConfirmationScreen.dart';
import 'package:obppay/screens/success_transfer_screen.dart';
import 'package:obppay/themes/app_colors.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.4,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Transférer",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // WALLET BALANCE CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primaryIndigo,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Votre solde",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "1 250 000 XOF",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // BENEFICIARY ID
            const Text(
              "ID du bénéficiaire (04-xxx-xxx)",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: idController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Ex: 04-123-456",
                filled: true,
                fillColor: Colors.grey.shade100,
                prefixIcon: const Icon(Icons.person_search_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // AMOUNT FIELD
            const Text(
              "Montant",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Ex: 10000",
                filled: true,
                fillColor: Colors.grey.shade100,
                prefixIcon: const Icon(Icons.payments_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // NOTE FIELD
            const Text(
              "Motif (facultatif)",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: noteController,
              keyboardType: TextInputType.text,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "Ex: Pour l’achat / remboursement",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // CONTINUE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Redirect to confirmation screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SuccessTransferScreen(
                        receiver: "tilisateur ObPay",
                        receiverId: idController.text,
                        amount: amountController.text,
                        note: noteController.text,
                        date: DateTime.now().toString(),
                        transactionId: "TX-${DateTime.now().millisecondsSinceEpoch}",
                      ),
                    ),
                  );


                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryIndigo,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Continuer",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),

            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
