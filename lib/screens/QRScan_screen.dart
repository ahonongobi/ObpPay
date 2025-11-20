import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'ProductDetailsScreen.dart';
import 'transfer_screen.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  String? lastResult;

  void _parseQR(String raw) {
    final parts = raw.split("|");
    final parsed = <String, String>{};

    for (var part in parts) {
      if (part.contains(":")) {
        final kv = part.split(":");
        parsed[kv[0]] = kv[1];
      }
    }

    // ---------- TRANSFER ----------
    if (parsed["TYPE"] == "TRANSFER") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TransferScreen(
            //predefinedReceiverId: parsed["ID"]!,
            //predefinedReceiverName: parsed["NAME"]!,
          ),
        ),
      );
      return;
    }

    // ---------- SHOP / MARKET ----------
    if (parsed["TYPE"] == "SHOP") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(
            id: 0,
            name: parsed["ITEM"]!,
            price: parsed["AMOUNT"]!,
            image: parsed["IMAGE"]!,
            description: parsed["DESC"]!,
          ),
        ),
      );
      return;
    }

    // Default
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("QR non reconnu")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scanner un QR ObPay"),
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 28),
          ),
          onPressed: () async {
            var res = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SimpleBarcodeScannerPage(
                  isShowFlashIcon: true,
                ),
              ),
            );

            if (res != null && res is String) {
              _parseQR(res);
            }
          },
          child: const Text(
            "Scanner maintenant",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
