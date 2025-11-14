import 'package:flutter/material.dart';
import 'package:obppay/screens/deposit_screen.dart';
import 'package:obppay/screens/main_layout.dart';
import 'package:obppay/screens/marketplace_screen.dart';
import 'package:obppay/themes/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // --- AppBar ---
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryIndigo,
          ),
        ),
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.qr_code_scanner,
              size: 26, color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.black),
            ),
          ),
        ],
      ),

      // ---------------- BODY ----------------
      body: Stack(
        children: [
          // --- BACKGROUND INDIGO WAVE CURVÉ ---
          CustomPaint(
            painter: IndigoWavePainter(),
            child: Container(
              height: 260,
              width: double.infinity,
            ),
          ),

          // --- CONTENT SCROLLABLE ---
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ===== WALLET CARD =====
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.primaryIndigo,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Solde du compte",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),

                      const Text(
                        "1 250 000 XOF",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ------ QUICK ACTIONS ------
                      GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.8,
                        ),
                        children: [
                          _actionRectButton(Icons.call_received, "Déposer",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const  MainLayout(initialIndex: 2)),
                              );
                            },),
                          _actionRectButton(Icons.call_made, "Retirer"),
                          _actionRectButton(Icons.sync_alt, "Transférer",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const MainLayout(initialIndex: 3)),
                              );
                            },),
                          _actionRectButtonColored(
                              Icons.storefront_outlined, "Boutique",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const MainLayout(initialIndex: 1)),
                              );
                            },),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ===== TRANSACTIONS =====
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Transactions récentes",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2A2A2A),
// gris foncé pro
                    ),
                  ),
                ),


                const SizedBox(height: 14),

                Column(
                  children: [
                    _transactionItem(
                      icon: Icons.arrow_downward,
                      title: "Transfert Reçu",
                      subtitle: "De Jean Dupont",
                      amount: "+25 000 XOF",
                      amountColor: Colors.green,
                      date: "Aujourd'hui, 14:30",
                    ),
                    _transactionItem(
                      icon: Icons.shopping_cart_outlined,
                      title: "Achat",
                      subtitle: "Marché Central",
                      amount: "-12 500 XOF",
                      amountColor: Colors.red,
                      date: "Hier, 10:15",
                    ),
                    _transactionItem(
                      icon: Icons.account_balance_wallet_outlined,
                      title: "Retrait DAB",
                      subtitle: "Agence Principale",
                      amount: "-50 000 XOF",
                      amountColor: Colors.red,
                      date: "02 Nov, 16:00",
                    ),

                    _transactionItem(
                      icon: Icons.account_balance_wallet_outlined,
                      title: "Retrait DAB",
                      subtitle: "Agence Principale",
                      amount: "-50 000 XOF",
                      amountColor: Colors.red,
                      date: "02 Nov, 16:00",
                    ),

                    _transactionItem(
                      icon: Icons.account_balance_wallet_outlined,
                      title: "Retrait DAB",
                      subtitle: "Agence Principale",
                      amount: "-50 000 XOF",
                      amountColor: Colors.red,
                      date: "02 Nov, 16:00",
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),


    );
  }

  // ----- RECTANGULAR WHITE BUTTON -----
  Widget _actionRectButton(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.black87),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----- RECTANGULAR COLORED BUTTON -----
  Widget _actionRectButtonColored(IconData icon, String title,{VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.accentGold,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----- TRANSACTION ITEM -----
  Widget _transactionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required Color amountColor,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.black54),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: amountColor),
              ),
              const SizedBox(height: 3),
              Text(
                date,
                style: const TextStyle(
                    fontSize: 11, color: Colors.black45),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// ===============================
//     WAVE CURVED BACKGROUND
// ===============================

class IndigoWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryIndigo
      ..style = PaintingStyle.fill;

    final path = Path();

    // TOP LEFT
    path.moveTo(0, 0);

    // TOP RIGHT
    path.lineTo(size.width, 0);

    // RIGHT DOWN
    path.lineTo(size.width, size.height * 0.55);

    // CURVE
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.80,
      0,
      size.height * 0.55,
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
