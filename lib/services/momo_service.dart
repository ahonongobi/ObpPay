import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api.dart';

class MomoService {
  static Future<Map<String, dynamic>> deposit({
    required String phone,
    required String amount,
    required String token,
  }) async {
    final url = Uri.parse("${Api.baseUrl}/momo/pay");

    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: {
        "msisdn": phone,
        "amount": amount,
      },
    );

    return jsonDecode(response.body);
  }
}
