import 'package:flutter/material.dart';
import 'package:obppay/screens/PaymentOptionsScreen.dart';
import 'package:obppay/themes/app_colors.dart';

class ProductDetailsScreen extends StatelessWidget {
  final String name;
  final String price;
  final String image;
  final String description;

  const ProductDetailsScreen({
    super.key,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.3,
        foregroundColor: Colors.black,
        title: const Text(
          "Détails du Produit",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // --- Image Produit ---
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Image.asset(
                image,
                width: double.infinity,
                height: 280,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Titre
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Prix
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryIndigo,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Bouton Acheter
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: intégrer ObPay checkout

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentOptionsScreen(
                              productName: name,
                              productPrice: price,
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
                        "Acheter maintenant",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
