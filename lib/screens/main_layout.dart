import 'package:flutter/material.dart';
import 'package:obppay/screens/dashboard_screen.dart';
import 'package:obppay/screens/marketplace_screen.dart';
import 'package:obppay/screens/deposit_screen.dart';
import 'package:obppay/screens/transfer_screen.dart';
import 'package:obppay/themes/app_colors.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;
  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  final pages = const [
    DashboardScreen(),
    MarketplaceScreen(),
    DepositScreen(),
    TransferScreen(),
    Placeholder(),

    //AgenciesScree(),
   // ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),

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
          //BottomNavigationBarItem(
             // icon: Icon(Icons.location_on_outlined), label: "Agences"),
          BottomNavigationBarItem(
              icon: Icon(Icons.sync_alt), label: "Transfert"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: "Profil"),
        ],
      ),
    );
  }
}
