import 'package:flutter/material.dart';
import 'package:obppay/themes/app_colors.dart';

class TransferConfirmationScreen extends StatelessWidget {
  final String beneficiaryId;
  final String amount;
  final String note;

  const TransferConfirmationScreen({
    super.key,
    required this.beneficiaryId,
    required this.amount,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    int parsedAmount = int.tryParse(amount) ?? 0;
    int currentBalance = 1250000; // fake user balance for now
    int newBalance = currentBalance - parsedAmount;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.4,
        foregroundColor: Colors.black,
        title: const Text(
          "Confirmation",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 10),

            // TITLE
            const Text(
              "Revérifiez avant de confirmer",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // MAIN CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // BENEFICIARY INFO
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Utilisateur ObPay",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            beneficiaryId,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // AMOUNT
                  const Text(
                    "Montant",
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  Text(
                    "$amount XOF",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // NOTE
                  if (note.isNotEmpty) ...[
                    const Text(
                      "Motif",
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    Text(
                      note,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // FEES
                  const Text(
                    "Frais",
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const Text(
                    "0 XOF",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // NEW BALANCE
                  const Text(
                    "Solde restant",
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  Text(
                    "$newBalance XOF",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // CONFIRM BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Run transaction + show success screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryIndigo,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Confirmer le transfert",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
