import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
//import 'package:image_gallery_saver/image_gallery_saver.dart';
//import 'package:gallery_saver/gallery_saver.dart';
import 'package:obppay/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';


class ObpPayCardScreen extends StatefulWidget {
  final String name;
  final String obpId;
  final String balance; // not displayed on card (only for future use)
  final String expiry; // not used now
  final String cvv; // not used now

  const ObpPayCardScreen({
    super.key,
    required this.name,
    required this.obpId,
    required this.balance,
    required this.expiry,
    required this.cvv,
  });

  @override
  State<ObpPayCardScreen> createState() => _ObpPayCardScreenState();
}

class _ObpPayCardScreenState extends State<ObpPayCardScreen>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late AnimationController _shineController;

  bool _showFront = true;
  double _tiltX = 0;
  double _tiltY = 0;

  final GlobalKey _cardKey = GlobalKey();
  late String formattedExpiry;

  @override
  void initState() {
    super.initState();

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    final DateTime registeredAt = DateTime.parse(widget.expiry);
    final DateTime exp =
    DateTime(registeredAt.year + 10, registeredAt.month);

    formattedExpiry =
    "${exp.month.toString().padLeft(2, '0')}/${exp.year % 100}";

  }

  @override
  void dispose() {
    _flipController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_flipController.isAnimating) return;

    if (_showFront) {
      _flipController.forward().then((_) {
        setState(() => _showFront = false);
        _flipController.reverse();
      });
    } else {
      _flipController.forward().then((_) {
        setState(() => _showFront = true);
        _flipController.reverse();
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _tiltY += details.delta.dx * 0.002; // left/right
      _tiltX -= details.delta.dy * 0.002; // up/down

      _tiltX = _tiltX.clamp(-0.3, 0.3);
      _tiltY = _tiltY.clamp(-0.4, 0.4);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _tiltX = 0;
      _tiltY = 0;
    });
  }

  Future<void> _saveCardAsImage() async {

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Fonctionnalité non disponible pour le moment."),
      ),
    );
    /*
    try {
      final boundary =
      _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // 1️⃣ Chemin temporaire
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/ObpPayCard_${DateTime.now().millisecondsSinceEpoch}.png';

      // 2️⃣ Sauvegarde du fichier temporaire
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      // 3️⃣ Sauvegarde dans la galerie (plugin moderne)
      final success = await GallerySaver.saveImage(filePath);

      if (!mounted) return;

      // 4️⃣ Feedback utilisateur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success == true
                ? "Carte sauvegardée dans la galerie 📸"
                : "Impossible de sauvegarder la carte",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur lors de la capture de la carte."),
        ),
      );
    }

    */
  }

  @override
  Widget build(BuildContext context) {

    final user = context.watch<UserProvider>().user;

    final registeredAt = DateTime.parse(user.registeredAt);
    final expiry = DateTime(registeredAt.year + 10, registeredAt.month);
    final expiryStr = "${expiry.month.toString().padLeft(2,'0')}/${expiry.year % 100}";

    final card = _ObpPayInteractiveCard(
      key: _cardKey,
      name: widget.name,
      obpId: widget.obpId,
      balance: widget.balance,
      expiry: formattedExpiry,
      cvv: widget.cvv,
      flipController: _flipController,
      shineController: _shineController,
      tiltX: _tiltX,
      tiltY: _tiltY,
      showFront: _showFront,
      onTap: _toggleFlip,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
    );
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Ma Carte ObpPay"),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0.5,
        foregroundColor: theme.colorScheme.onBackground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            const SizedBox(height: 10),

            // Carte centrée
            Center(child: card),

            const SizedBox(height: 20),

            // Bouton
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saveCardAsImage,
                icon: const Icon(Icons.download),
                label: const Text("Enregistrer la carte en image"),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

    );
  }
}

/// Internal widget: interactive card with shine, tilt & flip.
class _ObpPayInteractiveCard extends StatelessWidget {
  final String name;
  final String obpId;
  final String balance; // not used on visual card now
  final String expiry; // not used on visual card now
  final String cvv; // not used on visual card now
  final AnimationController flipController;
  final AnimationController shineController;
  final double tiltX;
  final double tiltY;
  final bool showFront;
  final VoidCallback onTap;
  final void Function(DragUpdateDetails) onPanUpdate;
  final void Function(DragEndDetails) onPanEnd;

  const _ObpPayInteractiveCard({
    super.key,
    required this.name,
    required this.obpId,
    required this.balance,
    required this.flipController,
    required this.shineController,
    required this.tiltX,
    required this.tiltY,
    required this.showFront,
    required this.onTap,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.expiry,
    required this.cvv,
  });

  // Mask obpId into card number format: 1234 •••• •••• 5678
  String get maskedNumber {
    final clean = obpId.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length <= 8) return clean;

    final first = clean.substring(0, 4);
    final last = clean.substring(clean.length - 4);
    return "$first  ••••  ••••  $last";
  }



  @override
  Widget build(BuildContext context) {
    final flipAnimation = Tween<double>(begin: 0, end: math.pi)
        .animate(CurvedAnimation(
      parent: flipController,
      curve: Curves.easeInOut,
    ));



    return GestureDetector(
      onTap: onTap,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: AnimatedBuilder(
        animation: Listenable.merge([flipAnimation, shineController]),
        builder: (context, child) {
          final isUnder = (flipAnimation.value > math.pi / 2.0);
          final displayFront = isUnder ? !showFront : showFront;

          final Matrix4 transform = Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateX(tiltX)
            ..rotateY(tiltY + flipAnimation.value);

          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: RepaintBoundary(
              child: Stack(
                children: [
                  _buildCardBase(displayFront),

                  // Shine effect overlay
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: shineController,
                        builder: (context, _) {
                          final double slide =
                              (shineController.value * 2) - 1; // -1 → 1
                          return Transform.translate(
                            offset: Offset(slide * 250, -50),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.0),
                                    Colors.white.withOpacity(0.22),
                                    Colors.white.withOpacity(0.0),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardBase(bool frontSide) {
    return Container(
      width: double.infinity,
      height: 210, // fixed height to avoid overflow
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4C44C1),
            Color(0xFF1E1B74),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 6),
            color: Colors.black26,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: frontSide ? _buildFront() : _buildBack(),
      ),
    );
  }

  Widget _buildFront() {



    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Top Row: Logo & NFC ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.account_balance_wallet_outlined,
                      color: Colors.white, size: 20),
                  SizedBox(width: 6),
                  Text(
                    "ObpPay",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),

              // NFC "contactless" icon
              Container(
                width: 34,
                height: 26,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFF6D365),
                      Color(0xFFFDA085),
                    ],
                  ),
                ),
                child: const Icon(Icons.wifi, color: Colors.white, size: 18),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // --- Chip ---
          Container(
            width: 50,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.amber.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
          ),

          const SizedBox(height: 18),

          // --- Masked Card Number ---
          Text(
            maskedNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          // --- Name + Expiry + Hologram ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // CARD HOLDER
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "CARD HOLDER",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),


              /*
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "VALID THRU",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 9,
                        ),
                      ),
                      Text(
                        expiry,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  // Hologram
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF5EFCE8),
                          Color(0xFF736EFE),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ],
              ), */
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Magnetic strip
          Container(
            height: 38,
            width: double.infinity,
            color: Colors.black87,
          ),
          const SizedBox(height: 16),

          // Signature + CVV
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 50,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: Text(
                  //"318",
                  cvv,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              obpId,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
