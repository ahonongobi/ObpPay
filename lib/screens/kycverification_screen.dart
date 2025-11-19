import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:obppay/providers/user_provider.dart';
import 'package:obppay/services/api.dart';
import 'package:obppay/services/kyc_service.dart';
import 'package:provider/provider.dart';
import '../themes/app_colors.dart';

class KycItem {
  final String type;
  final String status;

  KycItem({required this.type, required this.status});

  factory KycItem.fromJson(Map<String, dynamic>? json, String type) {
    if (json == null) {
      return KycItem(type: type, status: "missing");
    }
    return KycItem(
      type: type,
      status: json["status"] ?? "pending",
    );
  }
}

class KycVerificationScreen extends StatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  State<KycVerificationScreen> createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends State<KycVerificationScreen> {
  KycItem? idCard;
  KycItem? passport;
  KycItem? selfie;

  @override
  void initState() {
    super.initState();
    loadKycStatus();
  }

  Future<bool> pickAndUpload(String type) async {
    final provider = context.read<UserProvider>();
    final picker = ImagePicker();

    XFile? picked;

    if (type == "selfie") {
      picked = await picker.pickImage(source: ImageSource.camera);
    } else {
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


  Future<void> loadKycStatus() async {
    final token = context.read<UserProvider>().token;
    final url = Uri.parse("${Api.baseUrl}/kyc/status");

    final res = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    final data = jsonDecode(res.body);

    setState(() {
      idCard = KycItem.fromJson(data["id_card"], "id_card");
      passport = KycItem.fromJson(data["passport"], "passport");
      selfie = KycItem.fromJson(data["selfie"], "selfie");
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bool loading = (idCard == null || passport == null || selfie == null);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0.4,
        iconTheme: IconThemeData(color: theme.colorScheme.onBackground),
        title: Text(
          "Statut KYC",
          style: TextStyle(color: theme.colorScheme.onBackground),
        ),
      ),

      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              Icon(
                Icons.verified_user,
                size: 90,
                color: AppColors.primaryIndigo,
              ),

              const SizedBox(height: 20),

              Text(
                "Vérification en cours",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                "Nous vérifions vos documents d'identité.\n"
                    "Cela peut prendre quelques minutes.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  children: [
                    _detailWithRetry(
                      label: "Carte d'identité / CIP",
                      item: idCard!,
                      onRetry: () async {
                        final ok = await pickAndUpload("id_card");
                        if (ok) loadKycStatus();
                      },
                    ),
                    _detailWithRetry(
                      label: "Passeport",
                      item: passport!,
                      onRetry: () async {
                        final ok = await pickAndUpload("passport");
                        if (ok) loadKycStatus();
                      },
                    ),
                    _detailWithRetry(
                      label: "Selfie",
                      item: selfie!,
                      onRetry: () async {
                        final ok = await pickAndUpload("selfie");
                        if (ok) loadKycStatus();
                      },
                    ),

                    //_detail("Carte d'identité / CIP", idCard!.status),
                    //_detail("Passeport", passport!.status),
                   // _detail("Selfie", selfie!.status),
                  ],
                ),
              ),

              const Spacer(),

              Text(
                "Mis à jour automatiquement",
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }


  Widget _detailWithRetry({
    required String label,
    required KycItem item,
    required VoidCallback onRetry,
  }) {
    IconData icon;
    Color color;

    switch (item.status) {
      case "approved":
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case "rejected":
        icon = Icons.error;
        color = Colors.red;
        break;
      case "pending":
        icon = Icons.hourglass_empty;
        color = Colors.orange;
        break;
      default:
        icon = Icons.remove_circle_outline;
        color = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 6),
              Text(
                item.status.toUpperCase(),
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),

              // Bouton réessayer si rejeté
              if (item.status == "rejected") ...[
                const SizedBox(width: 10),
                TextButton(
                  onPressed: onRetry,
                  child: const Text(
                    "Réessayer",
                    style: TextStyle(color: Colors.blue),
                  ),
                )
              ],
            ],
          ),
        ],
      ),
    );
  }



  Widget _detail(String label, String status) {
    IconData icon;
    Color color;

    switch (status) {
      case "approved":
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case "rejected":
        icon = Icons.error;
        color = Colors.red;
        break;
      case "pending":
        icon = Icons.hourglass_empty;
        color = Colors.orange;
        break;
      default:
        icon = Icons.remove_circle_outline;
        color = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 6),
              Text(
                status.toUpperCase(),
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
