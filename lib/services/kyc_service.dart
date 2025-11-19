import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:obppay/services/api.dart';

class KycService {
  static Future<Map<String, dynamic>> upload({
    required String token,
    required File file,
    required String type,
  }) async {
    final url = Uri.parse("${Api.baseUrl}/kyc/upload");

    final request = http.MultipartRequest("POST", url);

    request.headers.addAll({
      "Authorization": "Bearer $token",
      "Accept": "application/json",   // 🚀 TRÈS IMPORTANT !!!
    });

    request.fields["type"] = type;

    request.files.add(
      await http.MultipartFile.fromPath("file", file.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print("🔵 RAW RESPONSE:");
    print(response.body);

    // Empêcher les crash JSON
    if (!response.body.trim().startsWith("{")) {
      return {
        "success": false,
        "error": "Réponse non-JSON du serveur",
        "raw": response.body,
      };
    }

    return jsonDecode(response.body);
  }
}

