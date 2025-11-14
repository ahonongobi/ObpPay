import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReceiptPDF {
  static Future<Uint8List> generate({
    required String sender,
    required String receiver,
    required String receiverId,
    required String amount,
    required String date,
    required String transactionId,
    required String note,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              // TITLE
              pw.Text(
                "Reçu de Transfert",
                style: pw.TextStyle(
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),

              pw.Text(
                "Merci d’avoir utilisé ObPay.",
                style: const pw.TextStyle(fontSize: 14),
              ),

              pw.Divider(height: 30),

              // SECTION : INFO TRANSACTION
              pw.Text(
                "Détails du transfert",
                style:
                pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),

              pw.SizedBox(height: 14),

              infoRow("Expéditeur", sender),
              infoRow("Bénéficiaire", receiver),
              infoRow("ID Bénéficiaire", receiverId),
              infoRow("Montant", "$amount XOF"),
              infoRow("Date", date),
              infoRow("Motif", note.isEmpty ? "-" : note),

              pw.SizedBox(height: 20),

              pw.Divider(),

              pw.SizedBox(height: 20),

              infoRow("ID de Transaction", transactionId),

              pw.Spacer(),

              pw.Center(
                child: pw.Text(
                  "ObPay • Paiements rapides et sécurisés",
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              )),
          pw.Text(value, style: const pw.TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
