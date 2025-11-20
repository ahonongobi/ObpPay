import 'package:flutter/material.dart';
import 'package:obppay/screens/PaymentOptionsScreen.dart';
import 'package:obppay/themes/app_colors.dart';

class ProductDetailsScreen extends StatelessWidget {
  final int id;
  final String name;
  final String price;
  final String image;
  final String description;

  const ProductDetailsScreen({

    super.key,
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0.3,
        foregroundColor: theme.colorScheme.onBackground,
        centerTitle: true,
        title: Text(
          "Détails du Produit",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onBackground,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // --- IMAGE PRODUIT ---
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Image.network(
                image,
                width: double.infinity,
                height: 280,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 280,
                  color: theme.colorScheme.surfaceVariant,
                  alignment: Alignment.center,
                  child: Icon(Icons.broken_image,
                      size: 60, color: theme.colorScheme.onSurface),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Titre du produit
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Prix
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryIndigo,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Bouton Acheter
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentOptionsScreen(
                              id: id,
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
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
