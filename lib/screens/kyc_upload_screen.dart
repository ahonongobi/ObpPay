import 'package:flutter/material.dart';
import 'package:obppay/screens/otp_screen.dart';
import 'package:obppay/themes/app_colors.dart';

class KycUploadScreen extends StatefulWidget {
  const KycUploadScreen({super.key});

  @override
  State<KycUploadScreen> createState() => _KycUploadScreenState();
}

class _KycUploadScreenState extends State<KycUploadScreen> {
  bool idUploaded = false;
  bool passportUploaded = false;
  bool selfieUploaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vérification d'identité"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Étape ---
              const Text(
                "Étape 2 sur 3",
                style: TextStyle(
                  color: AppColors.primaryIndigo,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: 0.66,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primaryIndigo,
                  ),
                  minHeight: 6,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Vérifiez votre identité",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Ajoutez vos documents pour sécuriser votre compte ObPay.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 28),

              // ---- Carte d'identité / CIP ----
              _buildKycCard(
                title: "Carte d'identité / CIP",
                subtitle: "Photo claire du recto (et verso si possible).",
                icon: Icons.badge_outlined,
                isUploaded: idUploaded,
                onTap: () {
                  // TODO: ouvrir picker / caméra
                  setState(() => idUploaded = true);
                },
              ),

              const SizedBox(height: 16),

              // ---- Passeport ----
              _buildKycCard(
                title: "Passeport",
                subtitle: "Page principale avec votre photo.",
                icon: Icons.travel_explore_outlined,
                isUploaded: passportUploaded,
                onTap: () {
                  // TODO: ouvrir picker / caméra
                  setState(() => passportUploaded = true);
                },
              ),

              const SizedBox(height: 16),

              // ---- Selfie ----
              _buildKycCard(
                title: "Selfie en temps réel",
                subtitle: "Prenez une photo de vous, visage bien visible.",
                icon: Icons.camera_alt_outlined,
                isUploaded: selfieUploaded,
                buttonLabel: "Prendre une photo",
                onTap: () {
                  // TODO: ouvrir caméra
                  setState(() => selfieUploaded = true);
                },
              ),

              const SizedBox(height: 32),

              // ---- Bouton Continuer ----
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: vérifier si tous les docs sont uploadés
                    // TODO: naviguer vers l'écran OTP (Étape 3)

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OtpScreen(purpose: "reset")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryIndigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Continuer",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (!(idUploaded && passportUploaded && selfieUploaded))
                const Text(
                  "Astuce : pour accélérer la validation, assurez-vous que vos photos sont nettes et lisibles.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKycCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isUploaded,
    required VoidCallback onTap,
    String buttonLabel = "Téléverser un document",
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryIndigo),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              if (isUploaded)
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 18),
                    SizedBox(width: 4),
                    Text(
                      "Ajouté",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              else
                const Text(
                  "Non ajouté",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 45,
            child: OutlinedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.upload_file, size: 18),
              label: Text(
                buttonLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isUploaded
                      ? AppColors.primaryIndigo
                      : Colors.grey.shade400,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
