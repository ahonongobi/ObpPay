import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:obppay/providers/user_provider.dart';
import 'package:obppay/services/api.dart';

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

  static Future<List<dynamic>> fetchTransactions(String token) async {
    final url = Uri.parse("${Api.baseUrl}/wallet/transactions");

    final response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load transactions");
    }
  }


}
