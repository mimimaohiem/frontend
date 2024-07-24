// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServicein {
  final String baseUrl = "http://10.0.2.2:8888";

  Future<http.Response> submitNote({
    required String note,
    required String jwtToken,
  }) async {
    return await http.post(
      Uri.parse("$baseUrl/submit"),
      body: jsonEncode({'note': note}),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
    );
  }






}
