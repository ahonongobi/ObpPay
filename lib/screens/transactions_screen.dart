import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:obppay/providers/user_provider.dart';
import 'package:obppay/themes/app_colors.dart';
import 'package:provider/provider.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  String filter = "all"; // all / in / out

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<UserProvider>().loadTransactions();
    });
  }

  IconData _mapTypeToIcon(String type) {
    switch (type) {
      case "deposit":
        return Icons.call_received;

      case "transfer_in":
        return Icons.arrow_downward;

      case "transfer_out":
        return Icons.arrow_upward;

      case "withdrawal":
        return Icons.account_balance_wallet_outlined;

      case "purchase":
        return Icons.shopping_cart_outlined;

      default:
        return Icons.swap_horiz;
    }
  }


  String _statusToFrench(String status) {
    switch (status.toLowerCase()) {
      case "completed":
      case "success":
      case "successful":
        return "Terminé";

      case "pending":
        return "En attente";

      case "failed":
      case "rejected":
        return "Échoué";

      case "cancelled":
        return "Annulé";

      default:
        return "Inconnu";
    }
  }


  Widget _statusBadge(String status) {
    Color bg;
    Color text;

    switch (status.toLowerCase()) {
      case "completed":
      case "success":
      case "successful":
        bg = Colors.green.shade100;
        text = Colors.green.shade800;
        break;

      case "pending":
        bg = Colors.orange.shade100;
        text = Colors.orange.shade800;
        break;

      case "failed":
      case "rejected":
        bg = Colors.red.shade100;
        text = Colors.red.shade800;
        break;

      default:
        bg = Colors.grey.shade300;
        text = Colors.grey.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        //status.toUpperCase(),
        _statusToFrench(status), // translate to French as fire
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }


  Color _mapAmountColor(String type) {
    return (type == "deposit" || type == "transfer_in")
        ? Colors.green
        : Colors.red;
  }

  String _mapTypeToTitle(String type) {
    switch (type) {
      case "deposit":
        return "Dépôt";

      case "transfer_in":
        return "Transfert Reçu";

      case "transfer_out":
        return "Transfert Envoyé";

      case "withdrawal":
        return "Retrait";

      case "purchase":
        return "Achat";

      default:
        return "Transaction";
    }
  }

  String _formatAmount(num amount, String currency, String type) {
    final sign = (type == "deposit" || type == "transfer_in") ? "+" : "-";
    return "$sign$amount $currency";
  }

  String _formatDate(String raw) {
    final dt = DateTime.parse(raw);
    return DateFormat("dd MMM • HH:mm", "fr_FR").format(dt);
  }

  bool _isIn(String type) {
    return type == "deposit" || type == "transfer_in";
  }

  bool _isOut(String type) {
    return type == "transfer_out" || type == "withdrawal" || type == "purchase";
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final txList = provider.transactions;

    // ---- FILTERING ----
    final filteredList = txList.where((tx) {
      if (filter == "in") return _isIn(tx["type"]);
      if (filter == "out") return _isOut(tx["type"]);
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Toutes les transactions",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0.4,
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await provider.loadTransactions();
        },

        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [

            // ---------------- FILTERS ----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _filterChip("Tous", "all"),
                _filterChip("Entrants", "in"),
                _filterChip("Sortants", "out"),
              ],
            ),

            const SizedBox(height: 20),

            // --------------- TRANSACTION LIST ---------------
            if (filteredList.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text(
                    "Aucune transaction",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 15,
                    ),
                  ),
                ),
              ),

            ...filteredList.map((tx) {
              final type = tx["type"];

              final rawAmount = tx["amount"];
              final amountNum = rawAmount is num ? rawAmount : double.tryParse(rawAmount.toString()) ?? 0;


              return AnimatedSlide(
                duration: const Duration(milliseconds: 250),
                offset: const Offset(0, 0.05),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: 1,
                  child: _transactionItem(
                    context,
                    icon: _mapTypeToIcon(type),
                    title: _mapTypeToTitle(type),
                    subtitle: tx["description"] ?? "",
                    amount:  _formatAmount(amountNum, tx["currency"], type),
                    amountColor: _mapAmountColor(type),
                    date: _formatDate(tx["created_at"]),
                    status: tx["status"] ?? "unknown",
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final isSelected = filter == value;

    return GestureDetector(
      onTap: () => setState(() => filter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryIndigo
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryIndigo
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onBackground,
          ),
        ),
      ),
    );
  }

  // ----- Transaction card (reuse your style) -----
  Widget _transactionItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required String amount,
        required Color amountColor,
        required String date,
        required String status,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Theme.of(context).iconTheme.color),
          const SizedBox(width: 12),

          // TITLE + SUBTITLE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // AMOUNT + DATE
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              _statusBadge(status),
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
                    fontSize: 11,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
