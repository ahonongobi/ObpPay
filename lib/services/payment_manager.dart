import 'package:obppay/services/momo_service.dart';

class PaymentManager {
  static Future<Map<String, dynamic>> process({
    required int method,
    required String phone,
    required String amount,
    required String token,
  }) async {

    try {
    switch (method) {

      case 1: // MTN MoMo
        return await MomoService.deposit(
          phone: phone,
          amount: amount,
          token: token,
        );

      case 2: // Moov Money (later)
        return {
          "success": false,
          "error": "Moov Money n'est pas encore disponible."
        };

      case 3: // Celtis (later)
        return {
          "success": false,
          "error": "Celtis n'est pas encore disponible."
        };

      default:
        return {
          "success": false,
          "error": "Méthode inconnue."
        };
    }
    } catch (e) {
      return {
        "success": false,
        "error": "Erreur système : $e"
      };
    }
  }
}
