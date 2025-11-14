import 'package:flutter/material.dart';
import 'package:obppay/themes/app_colors.dart';

class LoanRequestScreen extends StatefulWidget {
  const LoanRequestScreen({super.key});

  @override
  State<LoanRequestScreen> createState() => _LoanRequestScreenState();
}

class _LoanRequestScreenState extends State<LoanRequestScreen> {
  String? selectedCategory;
  final TextEditingController otherCategoryController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Demande d'aide",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ===== Title =====
            const Text(
              "Sélectionnez une catégorie",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
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
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryIndigo
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item["icon"] as IconData,
                          size: 28,
                          color: isSelected
                              ? AppColors.primaryIndigo
                              : Colors.black87,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item["label"] as String,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primaryIndigo
                                : Colors.black87,
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
                  const Text(
                    "Précisez la catégorie",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: otherCategoryController,
                    decoration: InputDecoration(
                      hintText: "Ex : Urgence familiale",
                      filled: true,
                      fillColor: Colors.grey.shade100,
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
                color: Colors.white,
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
                      const Text(
                        "Votre éligibilité",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      Row(
                        children: [
                          Text(
                            "${(eligibility * 100).toInt()}%",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: eligibility >= 0.5
                                  ? AppColors.primaryIndigo
                                  : Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            eligibility >= 0.5
                                ? Icons.check_circle
                                : Icons.warning_amber_rounded,
                            color: eligibility >= 0.5
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
                    tween: Tween<double>(begin: 0, end: eligibility),
                    builder: (context, value, _) {
                      return Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
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
                    eligibility >= 0.5
                        ? "Vous êtes éligible pour un prêt substantiel."
                        : "Éligibilité faible. Complétez plus d'informations.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
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
                  const Text(
                    "Montant souhaité",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Ex : 150 000 XOF",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),

            // ===== SUBMIT BUTTON =====
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  String categoryToSend = selectedCategory == "Autres"
                      ? otherCategoryController.text.trim()
                      : selectedCategory ?? "";

                  debugPrint("CATEGORY: $categoryToSend");
                  debugPrint("AMOUNT: ${amountController.text}");
                },
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
