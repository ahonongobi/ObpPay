import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:obppay/providers/user_provider.dart';
import 'package:obppay/screens/otp_screen.dart';
import 'package:obppay/services/kyc_service.dart';
import 'package:obppay/themes/app_colors.dart';
import 'package:provider/provider.dart';

class KycUploadScreen extends StatefulWidget {
  const KycUploadScreen({super.key});

  @override
  State<KycUploadScreen> createState() => _KycUploadScreenState();
}




class _KycUploadScreenState extends State<KycUploadScreen> {
  bool idUploaded = false;
  bool passportUploaded = false;
  bool selfieUploaded = false;

  bool get isKycComplete {
    return selfieUploaded && (idUploaded || passportUploaded);
  }

  void _checkAutoSubmit() {
    if (isKycComplete) {
      Future.delayed(const Duration(milliseconds: 200), () {
        _showSubmitDialog();
      });
    }
  }

  Future<void> _showSubmitDialog() async {
    final theme = Theme.of(context);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Soumettre les documents ?",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onBackground,
            ),
          ),
          content: Text(
            "Vous avez fourni les documents nécessaires. Souhaitez-vous les soumettre maintenant pour vérification ?",
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler", style: TextStyle(color: theme.colorScheme.onSurface)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _submitKycDocuments();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryIndigo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Soumettre"),
            ),
          ],
        );
      },
    );
  }

  void _submitKycDocuments() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Documents soumis pour vérification."),
        backgroundColor: Colors.green,
      ),
    );

    // TODO: Appeler ici votre API: /kyc/submit
  }




  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Future<bool> pickAndUpload(String type) async {
      final provider = context.read<UserProvider>();
      final picker = ImagePicker();

      XFile? picked;

      if (type == "selfie") {
        // Selfie depuis la caméra
        picked = await picker.pickImage(source: ImageSource.camera);
      } else {
        // ID / Passeport depuis la galerie
        picked = await picker.pickImage(source: ImageSource.gallery);
      }
      if (picked == null) return false;

      final file = File(picked.path);

      final result = await KycService.upload(
        token: provider.token!,
        file: file,
        type: type,
      );

      return result["success"] == true;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0.4,
        iconTheme: IconThemeData(color: theme.colorScheme.onBackground),
        title: Text(
          "Vérification d'identité",
          style: TextStyle(color: theme.colorScheme.onBackground),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // --- Étape ---
              Text(
                "Étape 1 sur 1",
                style: TextStyle(
                  color: AppColors.primaryIndigo,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: 1,
                  backgroundColor: theme.colorScheme.surface.withOpacity(0.4),
                  valueColor: const AlwaysStoppedAnimation(AppColors.primaryIndigo),
                  minHeight: 6,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                "Vérifiez votre identité",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                "Ajoutez vos documents pour sécuriser votre compte ObPay.",
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 28),

              // ---- Carte d'identité ----
              _buildKycCard(
                context: context,
                title: "Carte d'identité / CIP",
                subtitle: "Photo claire du recto (et verso si possible).",
                icon: Icons.badge_outlined,
                isUploaded: idUploaded,
                onTap: () async {
                  final result = await pickAndUpload('id_card');
                  if (result) {
                    setState(() => idUploaded = true);
                    _checkAutoSubmit();
                  }
                }
              ),

              const SizedBox(height: 16),

              // ---- Passeport ----
              _buildKycCard(
                context: context,
                title: "Passeport",
                subtitle: "Page principale avec votre photo.",
                icon: Icons.travel_explore_outlined,
                isUploaded: passportUploaded,
                onTap: () async {
                  final result = await pickAndUpload('passport');
                  if (result) {
                    setState(() => passportUploaded = true);
                    _checkAutoSubmit();
                  }
                }
              ),

              const SizedBox(height: 16),

              // ---- Selfie ----
              _buildKycCard(
                context: context,
                title: "Selfie en temps réel",
                subtitle: "Prenez une photo de vous, visage bien visible.",
                icon: Icons.camera_alt_outlined,
                isUploaded: selfieUploaded,
                buttonLabel: "Prendre une photo",
                onTap: () async {
                  final result = await pickAndUpload('selfie');
                  if (result) {
                    setState(() => selfieUploaded = true);
                    _checkAutoSubmit();
                  }
                }
              ),

              const SizedBox(height: 32),


              const SizedBox(height: 16),

              if (!(idUploaded && passportUploaded && selfieUploaded))
                Text(
                  "Astuce : pour accélérer la validation, assurez-vous que vos photos sont nettes et lisibles.",
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKycCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isUploaded,
    required VoidCallback onTap,
    String buttonLabel = "Téléverser un document",
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
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
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ),

              isUploaded
                  ? const Row(
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
                  : Text(
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
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 45,
            child: OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(Icons.upload_file,
                  size: 18, color: theme.colorScheme.onBackground),
              label: Text(
                buttonLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isUploaded
                      ? AppColors.primaryIndigo
                      : theme.dividerColor,
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
