import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:obppay/services/api.dart';

class CategoryService {
  static Future<List<dynamic>> getCategories() async {
    final res = await http.get(
      Uri.parse("${Api.baseUrl}/categories"),
      headers: {"Accept": "application/json"},
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return [];
  }
}
