import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:obppay/services/api.dart';

class WithdrawService {
  static Future<Map<String, dynamic>> requestWithdraw({
    required String token,
    required double amount,
    required String method,
    required String recipient,
  }) async {
    final url = Uri.parse("${Api.baseUrl}/withdraw/request");

    final res = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "amount": amount,
        "method": method,
        "recipient": recipient,
      }),
    );

    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> history(String token) async {
    final url = Uri.parse("${Api.baseUrl}/withdraw/history");

    final res = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    return jsonDecode(res.body)["data"] ?? [];
  }
}
