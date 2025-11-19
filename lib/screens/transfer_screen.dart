import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:obppay/providers/user_provider.dart';
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

  bool isCheckingUser = false;
  bool isLoading = false;
  bool highlightBalance = false;
  String? beneficiaryName;

  bool get isFormValid {
    return idController.text.isNotEmpty &&
        amountController.text.isNotEmpty &&
        double.tryParse(amountController.text) != null;
  }

  String formatObpId(String input) {
    String digits = input.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 2) digits = "${digits.substring(0, 2)}-${digits.substring(2)}";
    if (digits.length > 6) digits = "${digits.substring(0, 6)}-${digits.substring(6)}";
    if (digits.length > 10) digits = digits.substring(0, 10);

    return digits;
  }

  Future<void> fetchBeneficiaryName(String obpId) async {
    if (obpId.isEmpty) {
      setState(() => beneficiaryName = null);
      return;
    }

    setState(() => isCheckingUser = true);

    final token = context.read<UserProvider>().token;
    final url = Uri.parse("${Api.baseUrl}/user/by-obp/$obpId");

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
    } catch (_) {
      setState(() => beneficiaryName = null);
    }

    setState(() => isCheckingUser = false);
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
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Impossible de contacter le serveur."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = false);

    dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      data = {"message": "Erreur du serveur."};
    }

    if (response.statusCode == 200) {
      final newBalance = double.parse(data["new_balance"].toString());
      context.read<UserProvider>().updateBalance(newBalance);

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data["message"] ?? "Erreur lors du transfert."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0.4,
        iconTheme: IconThemeData(color: theme.colorScheme.onBackground),
        title: Text(
          "Transférer",
          style: TextStyle(
            color: theme.colorScheme.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🟪 SOLDE WALLET CARTE (adapte au thème)
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
                      color: highlightBalance
                          ? Colors.green.withOpacity(0.25)
                          : Colors.transparent,
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

            // ========================
            // 🟦 INPUTS ADAPTÉS THÈME
            // ========================

            _label("ID du bénéficiaire (04-xxx-xxx)", theme),
            const SizedBox(height: 6),
            _themedInput(
              controller: idController,
              theme: theme,
              hint: "Ex: 04-123-456",
              icon: Icons.person_search_outlined,
              onChanged: (value) {
                final formatted = formatObpId(value);
                if (formatted != value) {
                  idController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
                fetchBeneficiaryName(formatted);
              },
            ),

            if (isCheckingUser)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text("Recherche..."),
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

            _label("Montant", theme),
            const SizedBox(height: 6),
            _themedInput(
              controller: amountController,
              theme: theme,
              hint: "Ex: 10000",
              icon: Icons.payments_outlined,
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 20),

            _label("Motif (facultatif)", theme),
            const SizedBox(height: 6),
            _themedInput(
              controller: noteController,
              theme: theme,
              hint: "Ex: Pour achat / remboursement",
              maxLines: 2,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isFormValid && !isLoading
                    ? () async {
                  final confirmed = await _confirmDialog(theme);
                  if (confirmed) performTransfer();
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ============================
  // 🔧 WIDGETS réutilisables
  // ============================

  Widget _label(String text, ThemeData theme) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 15,
        color: theme.colorScheme.onBackground,
      ),
    );
  }

  Widget _themedInput({
    required TextEditingController controller,
    required ThemeData theme,
    required String hint,
    IconData? icon,
    Function(String)? onChanged,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: theme.colorScheme.onBackground),
      decoration: InputDecoration(
        prefixIcon: icon != null
            ? Icon(icon, color: theme.colorScheme.onBackground.withOpacity(0.7))
            : null,
        hintText: hint,
        hintStyle: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.4)),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: onChanged,
    );
  }

  Future<bool> _confirmDialog(ThemeData theme) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Confirmer le transfert",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onBackground,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("ID bénéficiaire : ${idController.text}",
                  style: TextStyle(color: theme.colorScheme.onBackground)),
              const SizedBox(height: 6),
              if (beneficiaryName != null)
                Text("Nom : $beneficiaryName",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onBackground,
                    )),
              const SizedBox(height: 6),
              Text("Montant : ${amountController.text} XOF",
                  style: TextStyle(color: theme.colorScheme.onBackground)),
              if (noteController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    "Motif : ${noteController.text}",
                    style: TextStyle(color: theme.colorScheme.onBackground),
                  ),
                ),
            ],
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
            )
          ],
        );
      },
    ) ??
        false;
  }
}
