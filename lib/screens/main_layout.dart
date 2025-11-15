import 'package:flutter/material.dart';
import 'package:obppay/providers/user_provider.dart';
import 'package:obppay/screens/dashboard_screen.dart';
import 'package:obppay/screens/kyc_upload_screen.dart';
import 'package:obppay/screens/loan_request_screen.dart';
import 'package:obppay/screens/marketplace_screen.dart';
import 'package:obppay/screens/deposit_screen.dart';
import 'package:obppay/screens/profile_screen.dart';
import 'package:obppay/screens/transfer_screen.dart';
import 'package:obppay/themes/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;
  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout>
    with SingleTickerProviderStateMixin {



  // 🔑 Keys du Quick Tour
  final GlobalKey menuKey = GlobalKey();
  final GlobalKey soldeKey = GlobalKey();
  final GlobalKey transferKey = GlobalKey();
  final GlobalKey depositKey = GlobalKey();



  late int currentIndex;

  // ====== HAMBURGER + DRAWER ANIMATION ======
  late AnimationController _menuController;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _slideAnimation;

  bool isMenuOpen = false;

  @override
  void initState() {
    super.initState();


// Charger user desde le backend dès qu’on arrive sur le dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUserFromApi();
    });

    currentIndex = widget.initialIndex;

    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _rotationAnimation = Tween<double>(begin: -0.20, end: 0.20)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_menuController);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0), // menu caché à droite
      end: const Offset(0.0, 0), // menu visible
    ).animate(
      CurvedAnimation(
        parent: _menuController,
        curve: Curves.easeOut,
      ),
    );

    // START QUICK TOUR ICI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ShowCaseWidget.of(context).startShowCase([
        menuKey,
      ]);
    });
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  final pages = const [
    DashboardScreen(),
    MarketplaceScreen(),
    DepositScreen(),
    TransferScreen(),
    ProfileScreen(),
    LoanRequestScreen(),
    KycUploadScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: Builder(
        builder: (context) {
          return Scaffold(
            body: Stack(
              children: [

                // ===== PAGE CONTENU =====
                IndexedStack(
                  index: currentIndex,
                  children: pages,
                ),

                // ===== DRAWER ANIMÉ =====
                AnimatedBuilder(
                  animation: _menuController,
                  builder: (context, child) {
                    return Stack(
                      children: [

                        // === OVERLAY SOMBRE ===
                        if (isMenuOpen)
                          GestureDetector(
                            onTap: () {
                              _menuController.reverse();
                              isMenuOpen = false;
                              setState(() {});
                            },
                            child: Container(
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ),

                        // === SLIDE MENU ===
                        SlideTransition(
                          position: _slideAnimation,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.65,
                              height: double.infinity,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(28),
                                  bottomLeft: Radius.circular(28),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  const SizedBox(height: 60),

                                  menuItem(Icons.home_outlined, "Accueil", () {
                                    setState(() => currentIndex = 0);
                                  }),

                                  menuItem(Icons.storefront_outlined, "Boutique", () {
                                    setState(() => currentIndex = 1);
                                  }),

                                  menuItem(Icons.call_received, "Déposer", () {
                                    setState(() => currentIndex = 2);
                                  }),

                                  menuItem(Icons.sync_alt, "Transfert", () {
                                    setState(() => currentIndex = 3);
                                  }),

                                  menuItem(Icons.support_agent, "Prêt/Aide", () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const LoanRequestScreen()),
                                    );
                                  }),

                                  menuItem(Icons.person_outline, "Profil", () {
                                    setState(() => currentIndex = 4);
                                  }),

                                  menuItem(Icons.verified_user, "Verifier ID", () {

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const KycUploadScreen()),
                                    );

                                  }),


                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // ===== HAMBURGER FLOATING =====
                Positioned(
                  right: 0,
                  top: MediaQuery.of(context).size.height * 0.50,

                  child: Showcase(
                    key: menuKey,
                    title: "Menu",
                    description: "Accédez rapidement aux fonctionnalités ici.",
                    child: GestureDetector(
                      onTap: () {
                        if (isMenuOpen) {
                          _menuController.reverse();
                          isMenuOpen = false;
                        } else {
                          _menuController.forward();
                          isMenuOpen = true;
                        }
                        setState(() {});
                      },
                      child: AnimatedBuilder(
                        animation: _rotationAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotationAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryIndigo,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                ),
                              ),
                              child: const Icon(
                                Icons.menu,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

              ],
            ),

            // ====== NAV BAR ======
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: currentIndex,
              selectedItemColor: AppColors.primaryIndigo,
              unselectedItemColor: Colors.black45,
              type: BottomNavigationBarType.fixed,
              onTap: (i) {
                setState(() => currentIndex = i);
              },
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined), label: "Accueil"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.storefront_outlined), label: "Boutique"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.call_received), label: "Déposer"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.sync_alt), label: "Transfert"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline), label: "Profil"),
              ],
            ),
          );
        },
      ),
    );
  }


  // ===== ITEM DU MENU LATÉRAL =====
  Widget menuItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        _menuController.reverse();
        isMenuOpen = false;
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Icon(icon, size: 26, color: AppColors.primaryIndigo),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }



}
