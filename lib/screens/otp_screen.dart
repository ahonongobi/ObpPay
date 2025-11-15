import 'package:flutter/material.dart';
import 'package:obppay/screens/RegisterSuccess_Screen.dart';
import 'dart:async';
import 'package:obppay/themes/app_colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:obppay/services/api.dart';


class OtpScreen extends StatefulWidget {
  final String purpose; // "register" or "reset"
  final String? name;
  final String? phone;
  final String? password;
  final String? idGenerated;

  const OtpScreen({super.key, required this.purpose,this.name,
    this.phone,
    this.password,this.idGenerated});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}


class _OtpScreenState extends State<OtpScreen> {
  List<String> code = ["", "", "", ""];
  int currentIndex = 0;

  int timerSeconds = 60;
  late Timer timer;

  @override
  void initState() {
    super.initState();
   // _sendOtp();
    startTimer();

  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerSeconds > 0) {
        setState(() => timerSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void onNumberTap(String value) {
    if (currentIndex < 4) {
      setState(() {
        code[currentIndex] = value;
        currentIndex++;
      });
    }

    if(currentIndex == 4){
      verifyOtp();
    }
  }

  void onDelete() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        code[currentIndex] = "";
      });
    }
  }

  bool get isComplete => code.join().length == 4;

  //final baseUrl = "http://10.0.2.2:8000/api";


  Future<void> registerUser() async {
    try {
      final response = await http.post(
        Uri.parse("${Api.baseUrl}/auth/register"),
        body: {
          "phone": widget.phone,
          "otp": code.join(),
          "obp_id": widget.idGenerated,
        },
      );

      print("REGISTER RESPONSE = ${response.body}");

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RegisterSuccessScreen(obpId: widget.idGenerated!),
          ),
        );
      } else {
        final body = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body["message"] ?? "Erreur")),
        );
      }
    } catch (e) {
      print("Erreur REGISTER → $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur réseau")),
      );
    }
  }

  // ------------------------------------------------------
  // HANDLE OTP SUCCESS BASED ON PURPOSE
  // ------------------------------------------------------
  void handleOtpSuccess() async {
    if (widget.purpose == "register") {
        await registerUser();

      //Navigator.pushReplacement(
       // context,
       // MaterialPageRoute(builder: (_) => const RegisterSuccessScreen()),
      //);
    }

    if (widget.purpose == "reset") {
      //Navigator.pushReplacement(
        //context,
        //MaterialPageRoute(builder: (_) => const NewPasswordScreen()),
      //);
    }
  }

  Future<void> _sendOtp() async {
    try {
      final response = await http.post(
        Uri.parse("${Api.baseUrl}/auth/send-otp"),
        body: {
          "phone": widget.phone,
        },
      );

      print("OTP envoyé → ${response.body}");
    } catch (e) {
      print("Erreur OTP → $e");
    }
  }

  Future<void> verifyOtp() async {
    await registerUser();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vérification OTP"),
      ),

      body: SafeArea(
        child: Column(
          children: [

            // ---------- CONTENU SCROLLABLE ----------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 10),

                    const Text(
                      "Étape 2 sur 2",
                      style: TextStyle(
                        color: AppColors.primaryIndigo,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: 1.0,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation(AppColors.primaryIndigo),
                        minHeight: 6,
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      "Vérifiez votre numéro",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Un code de confirmation à 4 chiffres vous a été envoyé.",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ----------- OTP BOXES (4) -----------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (i) {
                        final filled = code[i].isNotEmpty;
                        return Container(
                          width: 55,
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: filled
                                  ? AppColors.primaryIndigo
                                  : Colors.grey.shade300,
                              width: filled ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            code[i],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 20),

                    // ---- TIMER ----
                    Center(
                      child: timerSeconds > 0
                          ? Text(
                        "Renvoyer dans $timerSeconds s",
                        style: const TextStyle(color: Colors.black54),
                      )
                          : GestureDetector(
                        onTap: () async {
                          await _sendOtp();
                          setState(() => timerSeconds = 60);
                          startTimer();
                        },
                        child: const Text(
                          "Renvoyer le code",
                          style: TextStyle(
                            color: AppColors.primaryIndigo,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ---- BOUTON VÉRIFIER ----
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isComplete ? verifyOtp : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryIndigo,
                          disabledBackgroundColor: Colors.grey.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          "Vérifier",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: isComplete ? Colors.white : Colors.white70,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ---------- NUMPAD (RÉDUIT) ----------
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _numRow(["1", "2", "3"]),
            _numRow(["4", "5", "6"]),
            _numRow(["7", "8", "9"]),
            _numRow(["", "0", "<"]),
          ],
        ),
      ),
    );
  }

  // ---------- ROW ----------
  Widget _numRow(List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items
            .map((item) => item == ""
            ? const SizedBox(width: 60)
            : item == "<"
            ? _numButton(icon: Icons.backspace_outlined, onTap: onDelete)
            : _numButton(text: item, onTap: () => onNumberTap(item)))
            .toList(),
      ),
    );
  }

  // ---------- BUTTON ----------
  Widget _numButton({String? text, IconData? icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: icon != null
            ? Icon(icon, size: 22)
            : Text(
          text!,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
