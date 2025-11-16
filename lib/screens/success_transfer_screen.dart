import 'package:flutter/material.dart';
import 'package:obppay/providers/user_provider.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../main.dart';
import '../themes/app_colors.dart';
import 'receipt_pdf.dart';

class SuccessTransferScreen extends StatefulWidget {
  final String receiver;
  final String receiverId;
  final String amount;
  final String note;
  final String newBalance;

  final String transactionId;
  final String date;

  SuccessTransferScreen({
    super.key,
    required this.receiver,
    required this.receiverId,
    required this.amount,
    required this.note,
    required this.newBalance,
    String? transactionId,
    String? date,
  })  : transactionId = transactionId ??
      "TX-${DateTime.now().millisecondsSinceEpoch.toString().substring(3, 13)}",
        date = date ??
            DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

  @override
  State<SuccessTransferScreen> createState() => _SuccessTransferScreenState();
}

class _SuccessTransferScreenState extends State<SuccessTransferScreen> {


  @override
  void initState() {
    super.initState();
    triggerSuccessFeedback();
  }

  // VIBRATION + NOTIFICATION
  void triggerSuccessFeedback() async {
    // Vibrate
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 200);
    }

    // Notification
    showSuccessNotification(widget.amount, widget.receiver);
  }

  void showSuccessNotification(String amount, String receiver) {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'transfer_channel',
      'Transfers',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails notifDetails =
    NotificationDetails(android: androidDetails);

    flutterLocalNotificationsPlugin.show(
      1,
      "Transfert réussi",
      "Vous avez envoyé $amount XOF à $receiver",
      notifDetails,
    );
  }

  @override
  Widget build(BuildContext context) {

    final user = context.watch<UserProvider>().user;

    final username = user.fullName;
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [

            const SizedBox(height: 20),

            // SUCCESS ICON
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 120,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Transfert réussi !",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 20),

            _infoBox("Montant", "${widget.amount} XOF"),
            _infoBox("Destinataire", widget.receiver),
            _infoBox("ID ObPay", widget.receiverId),
            _infoBox("Motif", widget.note.isEmpty ? "-" : widget.note),
            _infoBox("Date", widget.date),
            _infoBox("ID Transaction", widget.transactionId),
            _infoBox("Nouveau solde", "${widget.newBalance} XOF"),

            const SizedBox(height: 20),

            // PDF Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final pdfBytes = await ReceiptPDF.generate(
                    sender: "$username",
                    receiver: widget.receiver,
                    receiverId: widget.receiverId,
                    amount: widget.amount,
                    date: widget.date,
                    transactionId: widget.transactionId,
                    note: widget.note,
                  );

                  await Printing.layoutPdf(
                    onLayout: (_) async => pdfBytes,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryIndigo,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("Télécharger le reçu PDF"),
              ),
            ),

            const SizedBox(height: 12),

            // BACK BUTTON
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primaryIndigo, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Retour à l'accueil",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ---------- Widget Info ----------
  Widget _infoBox(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
