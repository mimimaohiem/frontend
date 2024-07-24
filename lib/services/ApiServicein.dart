// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServicein {
  final String baseUrl = "http://your-server.com"; // Thay đổi theo địa chỉ server của bạn

  Future<bool> deleteNote(String noteId) async {
    var url = Uri.parse('$baseUrl/delete_note');
    var response = await http.delete(url, body: jsonEncode({'id': noteId}));
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete note');
    }
  }
}
