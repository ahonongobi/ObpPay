import 'package:flutter/material.dart';
import 'package:obppay/screens/ProductDetailsScreen.dart';
import 'package:obppay/themes/app_colors.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  int selectedCategory = 0;

  final List<String> categories = [
    "Tous",
    "Parcelles",
    "Agriculture",
    "Vivriers",
    "Élevage"
  ];

  final List<Map<String, dynamic>> products = [
    {
      "name": "Parcelle agricole fertile",
      "price": "25 000 000 F CFA",
      "image": "assets/images/prod1.jpg",
      "description":
      "Parcelle agricole extrêmement fertile, idéale pour la culture de maïs, manioc, légumes et fruits. Terrain bien exposé, accessible et prêt pour exploitation immédiate."
    },
    {
      "name": "Sac de riz local (25kg)",
      "price": "18 000 F CFA",
      "image": "assets/images/prod2.jpg",
      "description":
      "Riz local de haute qualité, non parfumé, cultivé dans nos régions. Très nutritif, parfait pour les familles et les restaurants."
    },
    {
      "name": "Engrais biologique (50kg)",
      "price": "12 500 F CFA",
      "image": "assets/images/prod3.jpg",
      "description":
      "Engrais 100% biologique, riche en nutriments essentiels. Améliore la fertilité du sol, augmente le rendement et protège les plantes naturellement."
    },
    {
      "name": "Assortiment de légumes frais",
      "price": "5 000 F CFA",
      "image": "assets/images/prod4.jpg",
      "description":
      "Panier de légumes frais directement du producteur : tomates, carottes, poivrons, oignons, aubergines. Idéal pour repas sains et équilibrés."
    },
    {
      "name": "Semences de coton certifiées",
      "price": "7 500 F CFA",
      "image": "assets/images/prod5.jpg",
      "description":
      "Semences de coton de haute qualité certifiées par les autorités agricoles. Germination rapide et rendement supérieur."
    },
    {
      "name": "Pot de miel 100% naturel",
      "price": "3 500 F CFA",
      "image": "assets/images/prod6.jpg",
      "description":
      "Miel pur, non chauffé, collecté de ruches traditionnelles. Riche en vitamines, minéraux et antioxydants. Un vrai boost naturel."
    },
    {
      "name": "Panier de fruits exotiques",
      "price": "10 000 F CFA",
      "image": "assets/images/prod7.jpg",
      "description":
      "Panier composé d’ananas, mangues, papayes, oranges et bananes. Idéal pour desserts, jus naturels et consommation fraîche."
    },
    {
      "name": "Kit d'irrigation goutte à goutte",
      "price": "45 000 F CFA",
      "image": "assets/images/prod8.jpg",
      "description":
      "Kit complet d’irrigation goutte à goutte permettant d’économiser 60% d’eau et d’augmenter le rendement. Installation simple et rapide."
    },
  ];


  Widget _buildProductCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(
              name: item["name"],
              price: item["price"],
              image: item["image"],
              description: item["description"] ?? "Aucune description",
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            AspectRatio(
              aspectRatio: 1.2,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: Image.asset(
                  item["image"],
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // CONTENT FLEXIBLE
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["name"],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      item["price"],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryIndigo,
                      ),
                    ),

                    const Spacer(),

                    Row(
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            size: 20, color: AppColors.primaryIndigo),
                        const SizedBox(width: 6),
                        const Text(
                          "Acheter",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,

        appBar: AppBar(
          elevation: 0.4,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          title: const Text(
            "Market Place",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),

        body: SafeArea(
          child: CustomScrollView(
            slivers: [

              // ----- HEADER -----
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // SEARCH BAR
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Rechercher des produits...",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.all(14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // CATEGORIES
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final bool isActive = index == selectedCategory;

                            return GestureDetector(
                              onTap: () => setState(() => selectedCategory = index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.primaryIndigo
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  categories[index],
                                  style: TextStyle(
                                    color: isActive ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),

              // ------ GRID FIXÉE DANS UNE SLIVERGRID ------
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildProductCard(products[index]),
                    childCount: products.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.60,
                  ),
                ),
              ),

              // ---- ESPACE POUR LE BOTTOM NAV ----
              // const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        )


    );
  }
}
