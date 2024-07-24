import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_lan1111/models/note.dart';

class ApiServicein {
  static const String baseUrl = 'http://10.0.2.2:8888';

  Future<List<Note>> fetchNotes() async {
    final prefs = await SharedPreferences.getInstance();
    String? jwtToken = prefs.getString('jwtToken');

    if (jwtToken == null) {
      throw Exception('JWT token is null');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/get_notes'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body)['notes'];
      List<Note> notes = body.map((dynamic item) => Note.fromJson(item)).toList();
      return notes;
    } else {
      throw Exception('Failed to load notes');
    }
  }

  Future<http.Response> submitNote({
    required String note,
    required String jwtToken,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/submit_note'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonEncode({'note': note}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to submit note');
    }

    return response;
  }

  // Delete a note
  Future<bool> deleteNote(String noteId) async {
    final prefs = await SharedPreferences.getInstance();
    String? jwtToken = prefs.getString('jwtToken');

    if (jwtToken == null) {
      throw Exception('JWT token is null');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/delete_note'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonEncode({'id': noteId}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete note');
    }
  }

}
