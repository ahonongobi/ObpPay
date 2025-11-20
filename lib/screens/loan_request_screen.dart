import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:obppay/providers/user_provider.dart';
import 'package:obppay/services/api.dart';
import 'package:obppay/themes/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';

class LoanRequestScreen extends StatefulWidget {
  const LoanRequestScreen({super.key});

  @override
  State<LoanRequestScreen> createState() => _LoanRequestScreenState();
}

class _LoanRequestScreenState extends State<LoanRequestScreen> {
  String? selectedCategory;
  final TextEditingController otherCategoryController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  // Exemple d’éligibilité (entre 0 et 1)
  double eligibility = 0.72; // 72%

  final categories = [
    {"label": "Loyer", "icon": Icons.home_outlined},
    {"label": "Éducation", "icon": Icons.school_outlined},
    {"label": "Business", "icon": Icons.business_center_outlined},
    {"label": "Santé", "icon": Icons.local_hospital_outlined},
    {"label": "Nourriture", "icon": Icons.restaurant_menu_outlined},
    {"label": "Autres", "icon": Icons.more_horiz},
  ];

  void showLoanNotification(String amount, String category) {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'loan_channel',          // Channel ID
      'Loan Requests',         // Channel name
      importance: Importance.max,
      priority: Priority.high,

      ongoing: true,           // Makes it persistent (sticky)
      autoCancel: false,       // Don’t remove it automatically
      playSound: true,
      enableVibration: true,

      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails notifDetails =
    NotificationDetails(android: androidDetails);

    flutterLocalNotificationsPlugin.show(
      2, // Unique ID
      "Demande de prêt envoyée",
      "Vous avez demandé $amount XOF ($category)",
      notifDetails,
    );
  }


  Future<void> submitLoanRequest() async {
    final token = context.read<UserProvider>().token;

    final url = Uri.parse("${Api.baseUrl}/loan/request");

    final categoryToSend = selectedCategory == "Autres"
        ? otherCategoryController.text.trim()
        : (selectedCategory ??  "Autre");

    final body = {
      "category": categoryToSend,
      "custom_category": selectedCategory == "Autres"
          ? otherCategoryController.text.trim()
          : null,
      "amount": double.tryParse(amountController.text) ?? 0,
      "notes": notesController.text.trim(),
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {

        showLoanNotification(
          amountController.text,
          categoryToSend ?? 'Autre',
        );
        // SUCCESS
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Demande envoyée avec succès 🎉"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context); // Back to previous screen
      } else {
        // ERROR
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "Erreur lors de l'envoi."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Impossible de contacter le serveur."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {

    final provider = context.watch<UserProvider>();
    final user = context.watch<UserProvider>().user;

    final score = provider.user.score;
    final progress = (score / 50).clamp(0, 1).toDouble(); // 0 → 1

    final isEligible = provider.loanEligibility == 1;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Demande d'aide/prêt",
          style: TextStyle(color: theme.colorScheme.onBackground),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: theme.colorScheme.onBackground),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ===== Title =====
             Text(
              "Sélectionnez une catégorie",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color:  theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),

            // ===== Categories Grid =====
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.9,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, i) {
                final item = categories[i];
                final isSelected = selectedCategory == item["label"];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = item["label"] as String;
                      if (selectedCategory != "Autres") {
                        otherCategoryController.clear();
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryIndigo
                            : theme.dividerColor,
                        width: 2,
                      ),
                      //color: Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item["icon"] as IconData,
                          size: 28,
                          color: isSelected
                              ? AppColors.primaryIndigo
                              : theme.colorScheme.onBackground,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item["label"] as String,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primaryIndigo
                                : theme.colorScheme.onBackground,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // ===== OTHER CATEGORY =====
            if (selectedCategory == "Autres")
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Précisez la catégorie",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: otherCategoryController,
                    decoration: InputDecoration(
                      hintText: "Ex : Urgence familiale",
                      hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.6)),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),

            // ===== PREMIUM ELIGIBILITY CARD =====
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Title row with icon + percentage ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Votre éligibilité",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onBackground,
                        ),
                      ),

                      Row(
                        children: [
                          Text(
                            "${provider.user.score} Points",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: provider.loanEligibility == 1
                                  ? AppColors.primaryIndigo
                                  : Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            provider.loanEligibility == 1
                                ? Icons.check_circle
                                : Icons.warning_amber_rounded,
                            color: provider.loanEligibility == 1
                                ? Colors.green
                                : Colors.orange,
                            size: 22,
                          ),
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 14),

                  // --- Gradient progress bar as premium ---

                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    tween: Tween<double>(begin: 0, end: progress),
                    builder: (context, value, _) {
                      return Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: theme.dividerColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: constraints.maxWidth * value,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFF6A400), // orange
                                        Color(0xFFF7CD2D), // yellow
                                        Color(0xFF1E6FFF), // blue
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  // --- Message text ---
                  Text(
                    provider.loanMessage,

                    style: TextStyle(
                      fontSize: 14,
                      color: provider.loanEligibility == 1 ? theme.colorScheme.onSurface : Colors.red,
                    ),
                  ),
                ],
              ),
            ),


            const SizedBox(height: 20),

            // ===== MONTANT À DEMANDER =====
            if (eligibility >= 0.5)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    "Montant souhaité",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color:  theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: amountController,
                    enabled: isEligible,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Ex : 150 000 XOF",
                      hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.6)),
                      filled: true,
                      fillColor: isEligible ? theme.colorScheme.surface :  theme.disabledColor.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),

             Text(
              "Motif (facultatif)",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: theme.colorScheme.onBackground,),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: notesController,
              enabled: isEligible,
              keyboardType: TextInputType.text,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "Ex: Pour l’achat / remboursement",
                hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6)),
                filled: true,
                fillColor: isEligible ? theme.colorScheme.surface : theme.disabledColor.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // ===== SUBMIT BUTTON =====
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isEligible ? submitLoanRequest : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryIndigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Soumettre la demande",
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
