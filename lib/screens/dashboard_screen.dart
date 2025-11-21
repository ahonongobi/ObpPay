import 'dart:convert';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:obppay/providers/user_provider.dart';
import 'package:obppay/screens/QRScan_screen.dart';
import 'package:obppay/screens/deposit_screen.dart';
import 'package:obppay/screens/main_layout.dart';
import 'package:obppay/screens/marketplace_screen.dart';
import 'package:obppay/screens/transactions_screen.dart';
import 'package:obppay/screens/withdrawal_screen.dart';
import 'package:obppay/services/api.dart';
import 'package:obppay/themes/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';



class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  bool highlightBalance = false;

// Confetti controller
  late ConfettiController _confettiController;


  // Floating text state
  bool showFloatingPoints = false;
  String floatingText = "+5";
  @override
  void initState() {
    super.initState();
    initializeDateFormatting("fr_FR", null);
    Future.microtask(() {
     // context.read<UserProvider>().refreshUser();
      final provider = context.read<UserProvider>();
      provider.refreshUser();
      provider.loadTransactions();
    });
    // Fetch balance when dashboard opens
    fetchWalletBalance();



    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    context.read<UserProvider>().fetchScore();

    triggerCelebration(3);
    // Listen to score updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().addListener(() {
        //triggerCelebration(5);
        final provider = context.read<UserProvider>();

        if (provider.lastPoints > 0) {
          triggerCelebration(provider.lastPoints);
        }
      });
    });

    // Listen AFTER frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().addListener(() {
        setState(() {
          highlightBalance = true;
        });

        Future.delayed(const Duration(milliseconds: 450), () {
          if (!mounted) return;
          if (mounted) {
            setState(() {
              highlightBalance = false;
            });
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void triggerCelebration(int points) {
    // 🎉 trigger falling confetti
    _confettiController.play();

    // Show floating +5 text
    setState(() {
      floatingText = "+$points";
      showFloatingPoints = true;
    });

    // Hide after animation
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      if (mounted) {
        setState(() => showFloatingPoints = false);
      }
    });

    // Green flash for balance (already implemented)
    setState(() => highlightBalance = true);
    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      if (mounted) setState(() => highlightBalance = false);
    });
  }



  Future<void> fetchWalletBalance() async {
    final token = context.read<UserProvider>().token;

    final response = await http.get(
      Uri.parse("${Api.baseUrl}/wallet/balance"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      context.read<UserProvider>().updateBalance(double.parse(data["balance"]));
    }
  }

  IconData _mapTypeToIcon(String type) {
    switch (type) {
      case "deposit":
        return Icons.call_received; // flèche vers le bas

      case "transfer_in":
        return Icons.arrow_downward; // reçu

      case "transfer_out":
        return Icons.arrow_upward; // envoyé

      case "purchase":
        return Icons.shopping_cart_outlined;

      case "withdrawal":
        return Icons.account_balance_wallet_outlined;

      default:
        return Icons.swap_horiz; // fallback icon
    }
  }

  String _mapTypeToTitle(String type) {
    switch (type) {
      case "deposit":
        return "Dépôt";

      case "transfer_in":
        return "Transfert Reçu";

      case "transfer_out":
        return "Transfert Envoyé";

      case "purchase":
        return "Achat";

      case "withdrawal":
        return "Retrait";

      default:
        return "Transaction";
    }
  }

  Color _mapAmountColor(String type) {
    if (type == "deposit" || type == "transfer_in") {
      return Colors.green; // argent entrant
    }
    return Colors.red; // argent sortant
  }

  String _formatAmount(num amount, String currency, String type) {
    final sign = (type == "deposit" || type == "transfer_in") ? "+" : "-";
    return "$sign$amount $currency";
  }

  String _formatDate(String raw) {
    final date = DateTime.parse(raw);
    return DateFormat("dd MMM yyyy • HH:mm", "fr_FR").format(date);
  }


  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    // ✅ Format here
    final formattedBalance = NumberFormat("#,###", "fr_FR")
        .format(user.balance);

    final obp_id = user.obpayId;
    final currency = user.currency;

    final provider = context.watch<UserProvider>();
    final txList = provider.transactions;


    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QRScanScreen()),
            );
          },
          icon:  Icon(Icons.qr_code_scanner,
              size: 26, color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainLayout(initialIndex: 4),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                backgroundImage: user.avatarUrl != null
                    ? NetworkImage(user.avatarUrl!)
                    : const NetworkImage(
                  "https://i.postimg.cc/nhqCkh77/default-avatar-icon-of-social-media-user-vector.jpg",
                ),
              ),

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
                        //color: Colors.black.withOpacity(0.15),
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.15),
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

                      //Text(
                        //"12 250 000 XOF",
                        //"$formattedBalance $currency",
                  //style: TextStyle(
                  // color: Colors.white,
                  //fontSize: 19,
                  // fontWeight: FontWeight.w800,
                  // ),
                      //),

                      AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: highlightBalance ? Colors.green.withOpacity(0.25) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "$formattedBalance  $currency",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),


                      const SizedBox(height: 10),


                    // ===== USER ID WITH COPY =====
                      Row(
                        children: [
                          Text(
                            "ID ObpPay: $obp_id",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 6),

                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("ID copié !"),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              Clipboard.setData( ClipboardData(text: "$obp_id"));
                            },
                            child: const Icon(
                              Icons.copy,
                              size: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
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
                          _actionRectButton(Icons.call_made, "Retirer",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const WithdrawRequestScreen()),
                              );
                            },),
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
                 Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Transactions récentes",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      //color: Color(0xFF2A2A2A), // gris foncé pro
                      color: Theme.of(context).colorScheme.onBackground,

                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        )
                      ],
                    ),
                  ),
                ),


                const SizedBox(height: 14),

                Column(
                  children: txList.map((tx) {
                    final type = tx["type"];

                    return _transactionItem(
                      icon: _mapTypeToIcon(type),
                      title: _mapTypeToTitle(type),
                      subtitle: tx["description"] ?? "",
                      amount: _formatAmount(
                        double.tryParse(tx["amount"].toString()) ?? 0,
                        tx["currency"].toString(),
                        type,
                      ),
                      amountColor: _mapAmountColor(type),
                      date: _formatDate(tx["created_at"]),

                    );
                  }).toList(),
                ),
/*
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
                  ],
                ),
                */

                // add beautiful Montrer toutes les transactions button
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AllTransactionsScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryIndigo,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Voir toutes les transactions",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.chevron_right_rounded,
                          color: Theme.of(context).colorScheme.onBackground),
                    ],
                  ),
                ),
              ),


              const SizedBox(height: 40),
              ],
            ),
          ),

          // 🎉 Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              emissionFrequency: 0.04,
              numberOfParticles: 25,
              maxBlastForce: 30,      // plus fort
              minBlastForce: 10,
              gravity: 0.2,           // tombe plus doucement
              particleDrag: 0.02,
              // ❤️ Ajout : rendre les confettis plus grands
              colors: [
                Colors.green.withOpacity(0.9),
                Colors.blue.withOpacity(0.9),
                Colors.orange.withOpacity(0.9),
                Colors.purple.withOpacity(0.9),
              ],
              // Ajouter des formes personnalisées (bigger)
              createParticlePath: (size) {
                final rnd = Random().nextInt(3);
                switch (rnd) {
                  case 0:
                    return Path()
                      ..addOval(Rect.fromCircle(center: Offset.zero, radius: 6)); // 🔥 confetti rond ++
                  case 1:
                    return Path()
                      ..addRect(Rect.fromLTWH(-4, -4, 12, 12)); // 🔥 carré
                  default:
                    return Path()
                      ..addPolygon([
                        Offset(0, -10),
                        Offset(8, 10),
                        Offset(-8, 10),
                      ], true); // 🔥 triangle agrandi
                }
              },
            ),

          ),

          // 🔼 Floating +5 text animation
          if (showFloatingPoints)
            Positioned(
              top: 120,
              left: MediaQuery.of(context).size.width / 2 - 40,
              child: AnimatedOpacity(
                opacity: showFloatingPoints ? 1 : 0,
                duration: const Duration(milliseconds: 600),
                child: AnimatedSlide(
                  offset: showFloatingPoints
                      ? const Offset(0, -1.5)
                      : const Offset(0, 0),
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      floatingText,
                      style:  TextStyle(
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.surface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
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
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Theme.of(context).iconTheme.color),
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
            Icon(icon, size: 20, color: Theme.of(context).iconTheme.color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.surface,

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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Theme.of(context).iconTheme.color),
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
                  style: TextStyle(
                      fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
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
                style: TextStyle(
                    fontSize: 11, color: Theme.of(context).colorScheme.onSurface,),
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
