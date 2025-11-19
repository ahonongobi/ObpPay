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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Vérification OTP",
          style: TextStyle(color: theme.colorScheme.onBackground),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0.4,
        iconTheme: IconThemeData(color: theme.colorScheme.onBackground),
      ),

      body: SafeArea(
        child: Column(
          children: [

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 10),

                    Text(
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
                        backgroundColor: theme.colorScheme.surface.withOpacity(0.4),
                        valueColor: const AlwaysStoppedAnimation(AppColors.primaryIndigo),
                        minHeight: 6,
                      ),
                    ),

                    const SizedBox(height: 30),

                    Text(
                      "Vérifiez votre numéro",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Un code de confirmation à 4 chiffres vous a été envoyé.",
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // OTP BOXES
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (i) {
                        final filled = code[i].isNotEmpty;
                        return Container(
                          width: 55,
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: filled
                                  ? AppColors.primaryIndigo
                                  : theme.dividerColor,
                              width: filled ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            code[i],
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onBackground,
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: timerSeconds > 0
                          ? Text(
                        "Renvoyer dans $timerSeconds s",
                        style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.7)),
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

                    // BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isComplete ? verifyOtp : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryIndigo,
                          disabledBackgroundColor:
                          theme.colorScheme.onSurface.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          "Vérifier",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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

      // NUMPAD
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        color: theme.colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _numRow(["1", "2", "3"], theme),
            _numRow(["4", "5", "6"], theme),
            _numRow(["7", "8", "9"], theme),
            _numRow(["", "0", "<"], theme),
          ],
        ),
      ),
    );
  }

// ---------- NUMPAD ROW ----------
  Widget _numRow(List<String> items, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.map((item) {
          if (item == "") return const SizedBox(width: 60);
          if (item == "<") return _numButton(icon: Icons.backspace_outlined, theme: theme, onTap: onDelete);
          return _numButton(text: item, theme: theme, onTap: () => onNumberTap(item));
        }).toList(),
      ),
    );
  }

// ---------- NUMPAD BUTTON ----------
  Widget _numButton({String? text, IconData? icon, required VoidCallback onTap, required ThemeData theme}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: icon != null
            ? Icon(icon, size: 22, color: theme.iconTheme.color)
            : Text(
          text!,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onBackground,
          ),
        ),
      ),
    );
  }
}
