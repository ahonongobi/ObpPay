import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:obppay/providers/user_provider.dart';
import 'package:obppay/screens/ConfirmationScreen.dart';
import 'package:obppay/screens/success_transfer_screen.dart';
import 'package:obppay/services/api.dart';
import 'package:obppay/themes/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  bool isValid = false;
  bool loading = false;

  bool isLoading = false;

  String? beneficiaryName;
  bool isCheckingUser = false;
  bool highlightBalance = false;

  bool get isFormValid {
    return idController.text.isNotEmpty &&
        amountController.text.isNotEmpty &&
        double.tryParse(amountController.text) != null;
  }

  String formatObpId(String input) {
    // Remove all non-digits
    String digits = input.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 2) {
      digits = digits.substring(0, 2) + '-' + digits.substring(2);
    }
    if (digits.length > 6) {
      digits = digits.substring(0, 6) + '-' + digits.substring(6);
    }
    if (digits.length > 10) {
      digits = digits.substring(0, 10); // Max: 04-123-456 (10 chars)
    }

    return digits;
  }


  Future<void> performTransfer() async {
    setState(() => isLoading = true);

    final token = context.read<UserProvider>().token;
    final url = Uri.parse("${Api.baseUrl}/wallet/transfer");

    http.Response response;

    try {
      response = await http.post(


        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "to_obp_id": idController.text.trim(),
          "amount": double.parse(amountController.text),
          "note": noteController.text.trim(),
        }),
      );

      //print("RAW RESPONSE: ${response.body}");
      //print("STATUS: ${response.statusCode}");
      //print("TOKEN USED: $token");


    } catch (e) {
      setState(() => isLoading = false);

      // Network error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Impossible de contacter le serveur."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = false);

    // Try to JSON-decode safely
    dynamic data;
    try {
      data = jsonDecode(response.body);


    } catch (_) {
      data = {"message": "Erreur du serveur. Réponse non valide."};
    }

    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => isLoading = false);


    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);
      final newBalance = double.parse(data["new_balance"].toString());

      // UPDATE PROVIDER
      context.read<UserProvider>().updateBalance(newBalance);
      // SUCCESS
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SuccessTransferScreen(
            receiver: beneficiaryName ?? "Utilisateur ObPay",
            receiverId: idController.text,
            amount: amountController.text,
            note: noteController.text,
            newBalance: newBalance.toString(),
          ),
        ),
      );
    } else {
      // ERROR
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            data["message"] ??
                "Erreur lors du transfert (${response.statusCode})",
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }


  Future<void> fetchBeneficiaryName(String obpId) async {
    if (obpId.isEmpty) {
      setState(() => beneficiaryName = null);
      return;
    }

    setState(() => isCheckingUser = true);

    final token = context.read<UserProvider>().token;
    final url = Uri.parse("http://10.0.2.2:8000/api/user/by-obp/$obpId");

    try {
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => beneficiaryName = data["name"]);
      } else {
        setState(() => beneficiaryName = null);
      }
    } catch (e) {
      setState(() => beneficiaryName = null);
    }

    setState(() => isCheckingUser = false);
  }



  Future<bool> showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Confirmer le transfert",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ID bénéficiaire : ${idController.text}",
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 6),
                if (beneficiaryName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "Nom : $beneficiaryName",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),

                Text(
                  "Montant : ${amountController.text} XOF",
                  style: const TextStyle(fontSize: 15),
                ),
                if (noteController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "Motif : ${noteController.text}",
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryIndigo,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Super"),
            ),
          ],
        );
      },
    ) ??
        false;
  }




  @override
  Widget build(BuildContext context) {

    final user = context.watch<UserProvider>().user;
    final currency = user.currency;
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
                children: [
                  Text(
                    "Votre solde",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: highlightBalance ? Colors.green.withOpacity(0.25) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${user.balance ?? 0} XOF",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
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
              onChanged: (value) {

                final formatted = formatObpId(value);

                if (formatted != value) {
                  idController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
                setState(() {});
                fetchBeneficiaryName(value.trim());
              },
            ),
            if (isCheckingUser)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  "Recherche...",
                  style: TextStyle(color: Colors.blueGrey),
                ),
              )
            else if (beneficiaryName != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  "Nom: $beneficiaryName",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              )
            else if (idController.text.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    "Utilisateur introuvable",
                    style: TextStyle(color: Colors.red),
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
              onChanged: (_) => setState(() {}),

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
                onPressed: isFormValid && !isLoading
                    ? () async {
                  final confirm = await showConfirmationDialog();
                  if (confirm) performTransfer();
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryIndigo,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : const Text(
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
