import 'dart:async';
import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../themes/app_colors.dart';
import 'ProductDetailsScreen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  List categories = [];
  List products = [];

  int selectedCategory = 0;
  String searchQuery = "";

  bool loadingProducts = true;
  bool loadingCategories = true;

  TextEditingController searchController = TextEditingController();
  Timer? searchDebounce;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  // ------------------------------
  // LOAD CATEGORIES
  // ------------------------------
  Future<void> loadCategories() async {
    final data = await ProductService.getCategories();

    setState(() {
      categories = [
        {"id": null, "name": "Tous"},
        ...data,
      ];
      loadingCategories = false;
    });

    loadProducts();
  }

  // ------------------------------
  // LOAD PRODUCTS
  // ------------------------------
  Future<void> loadProducts() async {
    setState(() => loadingProducts = true);

    final categoryId = categories[selectedCategory]["id"];

    final data = await ProductService.getProducts(
      categoryId: categoryId,
      search: searchQuery,
    );

    setState(() {
      products = data;
      loadingProducts = false;
    });
  }

  // ------------------------------
  // PRODUCT CARD
  // ------------------------------
  Widget _buildProductCard(Map<String, dynamic> item) {
    final theme = Theme.of(context);

    final priceValue = double.tryParse(item["price"].toString()) ?? 0.0;
    final priceText = "${priceValue.toStringAsFixed(0)} ${item["currency"]}";


    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(
              id: item["id"],
              name: item["name"],
              price: priceText,
              image: item["image"],
              description: item["description"] ?? "Aucune description",
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            AspectRatio(
              aspectRatio: 1.2,
              child: ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(14)),
                child: Image.network(
                  item["image"],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: theme.colorScheme.surfaceVariant,
                    alignment: Alignment.center,
                    child: Icon(Icons.broken_image,
                        size: 40, color: theme.colorScheme.onSurface),
                  ),
                ),
              ),
            ),

            // CONTENT
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
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      priceText,
                      style: const TextStyle(
                        fontSize: 11,
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
                        Text(
                          "Acheter",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ------------------------------
  // BUILD UI
  // ------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0.4,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.onBackground,
        title: const Text("Market Place",
            style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),

      body: loadingCategories
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Column(
          children: [
            // --------------------
            // SEARCH BAR
            // --------------------
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  searchQuery = value;

                  searchDebounce?.cancel();
                  searchDebounce =
                      Timer(const Duration(milliseconds: 400), () {
                        loadProducts();
                      });
                },
                decoration: InputDecoration(
                  hintText: "Rechercher...",
                  prefixIcon: Icon(Icons.search,
                      color: theme.colorScheme.onSurface),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // --------------------
            // CATEGORIES
            // --------------------
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final bool isActive = index == selectedCategory;

                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedCategory = index);
                      loadProducts();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primaryIndigo
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        categories[index]["name"],
                        style: TextStyle(
                          color: isActive
                              ? Colors.white
                              : theme.colorScheme.onBackground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // --------------------
            // PRODUCTS GRID
            // --------------------
            Expanded(
              child: loadingProducts
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                padding:
                const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.60,
                ),
                itemCount: products.length,
                itemBuilder: (_, i) =>
                    _buildProductCard(products[i]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
