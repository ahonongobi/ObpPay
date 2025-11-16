import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:obppay/providers/user_provider.dart';

class WalletService {
  static const String baseUrl = "http://10.0.2.2:8000/api";

  static Future<Map<String, dynamic>> transfer({
    required String token,
    required String toObpId,
    required double amount,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/wallet/transfer"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "to_obp_id": toObpId,
        "amount": amount,
      }),
    );

    return {
      "status": response.statusCode,
      "body": jsonDecode(response.body)
    };
  }
}
