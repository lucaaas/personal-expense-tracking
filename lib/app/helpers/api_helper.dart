import 'dart:convert';

import 'package:http/http.dart' as http;

abstract mixin class ApiHelper {
  final String _baseUrl = 'https://personal-expense-trackin-5baeb-default-rtdb.firebaseio.com';

  String get entity;

  Uri get entityUrl => Uri.parse('$_baseUrl/$entity.json');

  Future<http.Response> post(Map<String, dynamic> data) {
    return http.post(entityUrl, body: json.encode(data));
  }

  Future<http.Response> fetch() {
    return http.get(entityUrl);
  }

  Future<http.Response> patch(Map<String, dynamic> data) {
    final url = Uri.parse('$_baseUrl/$entity.json');
    return http.patch(url, body: json.encode(data));
  }
}
