import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:obppay/screens/kyc_upload_screen.dart';
import 'package:obppay/screens/otp_screen.dart';
import 'package:obppay/services/api.dart';
import 'package:obppay/themes/app_colors.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';




class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _hidePass1 = true;
  bool _hidePass2 = true;

  bool passwordsMatch = true;


  late String obpayNumber;
  bool isFormValid = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pass1Controller = TextEditingController();
  final TextEditingController _pass2Controller = TextEditingController();



  void _validateForm() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final pass1 = _pass1Controller.text.trim();
    final pass2 = _pass2Controller.text.trim();


    setState(() {
      passwordsMatch = pass1 == pass2;

      isFormValid =
          name.isNotEmpty &&
              phone.isNotEmpty &&
              pass1.isNotEmpty &&
              pass2.isNotEmpty &&
              passwordsMatch;
    });
  }

  void showTopSnackBar(BuildContext context, String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
          top: 20,
          left: 16,
          right: 16,
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }


  Future<void> startRegistration() async {
    try {
      final response = await http.post(
        Uri.parse("${Api.baseUrl}/auth/register"),
        headers: {"Accept": "application/json"},
        body: {
          "name": _nameController.text.trim(),
          "phone": _phoneController.text.trim(),
          "password": _pass1Controller.text.trim(),
        },
      );

      print(response.body);


      if (response.statusCode == 200 || response.statusCode == 201) {
        // Aller à l'écran OTP
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(
              purpose: "register",
              name: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
              password: _pass1Controller.text.trim(),
              idGenerated: obpayNumber,
            ),
          ),
        );
      } else {
        // ---- ERREUR BACKEND ----
        final data = json.decode(response.body);

        String errorMsg = "Erreur";

        if (data["errors"] != null) {
          // Prend la première erreur disponible
          errorMsg = data["errors"].values.first[0];
        } else if (data["message"] != null) {
          errorMsg = data["message"];
        }

        showTopSnackBar(context, errorMsg);

      }
    } catch (e, stack) {
      print("🔴 ERREUR startRegistration → $e");
      print(stack);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur réseau: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  @override
  void initState() {
    super.initState();
    obpayNumber = generateObPayNumber();
  }

  // -- Generate random ObPay ID 04-XXX-XXX --
  String generateObPayNumber() {
    final random = Random();
    int a = 100 + random.nextInt(900); // 100–999
    int b = 100 + random.nextInt(900);
    return "04-$a-$b";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 10),

              // --- Title ---
              const Text(
                "Créez votre compte ObPay",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 20),

              // --- Step indicator ---
              const Text(
                "Étape 1 sur 2",
                style: TextStyle(
                  color: AppColors.primaryIndigo,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 6),

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: 0.33,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primaryIndigo,
                  ),
                  minHeight: 6,
                ),
              ),

              const SizedBox(height: 30),

              // -------- INPUTS --------

              const Text("Nom complet",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),

              TextField(
                controller: _nameController,
                onChanged: (_) => _validateForm(),
                decoration: InputDecoration(
                  hintText: "Votre nom et prénoms",
                ),
              ),

              const SizedBox(height: 25),

              const Text("Numéro de téléphone",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),

              TextField(
                controller: _phoneController,
                onChanged: (_) => _validateForm(),
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: "Ex: 0789123456",
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),

              const SizedBox(height: 25),

              const Text("Mot de passe",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),

              TextField(
                controller: _pass1Controller,
                onChanged: (_) => _validateForm(),

                obscureText: _hidePass1,
                decoration: InputDecoration(
                  hintText: "********",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() => _hidePass1 = !_hidePass1);
                    },
                    child: Icon(
                      _hidePass1 ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text("Confirmer le mot de passe",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),

              TextField(
                controller: _pass2Controller,
                onChanged: (_) => _validateForm(),
                obscureText: _hidePass2,
                decoration: InputDecoration(
                  hintText: "********",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() => _hidePass2 = !_hidePass2);
                    },
                    child: Icon(
                      _hidePass2 ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
              ),
              if (!passwordsMatch && _pass2Controller.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0, left: 4),
                  child: Text(
                    "Les mots de passe ne correspondent pas",
                    style: TextStyle(color: Colors.red.shade600, fontSize: 12),
                  ),
                ),


              const SizedBox(height: 35),

              // --- OBPAY NUMBER GENERATION CARD ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.grey.shade100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Générer un numéro ObPay",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Votre identifiant unique pour les transactions.",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            obpayNumber,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryIndigo,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: obpayNumber),
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Numéro copié !"),
                                  duration: Duration(milliseconds: 600),
                                ),
                              );
                            },
                            child: const Icon(Icons.copy, size: 22),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // ---- Continue Button ----
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isFormValid
                      ? () async {
                    await startRegistration();
                  }
                      : null, // désactive le bouton si false

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    isFormValid ? AppColors.primaryIndigo : Colors.grey.shade400,
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


              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
