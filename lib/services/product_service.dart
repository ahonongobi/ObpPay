import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api.dart';

class ProductService {
  static Future<List<dynamic>> getProducts({
    int? categoryId,
    String? search,
  }) async {
    final uri = Uri.parse("${Api.baseUrl}/products").replace(
      queryParameters: {
        if (categoryId != null) "category_id": categoryId.toString(),
        if (search != null && search.isNotEmpty) "search": search,
      },
    );

    final res = await http.get(uri, headers: {
      "Accept": "application/json",
    });

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    return [];
  }

  static Future<List<dynamic>> getCategories() async {
    final uri = Uri.parse("${Api.baseUrl}/categories");

    final res = await http.get(uri, headers: {
      "Accept": "application/json",
    });

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    return [];
  }
}
