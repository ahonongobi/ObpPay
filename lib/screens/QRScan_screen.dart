import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'ProductDetailsScreen.dart';
import 'transfer_screen.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  bool _isScanning = false;

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
            // predefinedReceiverId: parsed["ID"]!,
            // predefinedReceiverName: parsed["NAME"]!,
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

    // Default case
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("QR non reconnu")),
    );
  }

  void _startScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const _FullScreenScanner(),
      ),
    );

    if (result != null && result is String) {
      _parseQR(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scanner un QR ObPay"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _startScanner,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 28),
          ),
          child: const Text(
            "Scanner maintenant",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

///
/// FULLSCREEN SCANNER PAGE
///
class _FullScreenScanner extends StatefulWidget {
  const _FullScreenScanner({super.key});

  @override
  State<_FullScreenScanner> createState() => _FullScreenScannerState();
}

class _FullScreenScannerState extends State<_FullScreenScanner> {
  bool scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (BarcodeCapture capture) {
              if (!scanned) {
                scanned = true;

                final List<Barcode> barcodes = capture.barcodes;
                final String? value =
                barcodes.isNotEmpty ? barcodes.first.rawValue : null;

                if (value != null) {
                  Navigator.pop(context, value);
                }
              }
            },
          ),




          // Overlay (dark with a hole)
          Container(
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.9),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              width: 260,
              height: 260,
            ),
          ),

          // Close button
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, size: 30, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
