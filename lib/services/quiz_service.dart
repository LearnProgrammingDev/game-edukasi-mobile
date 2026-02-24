import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class QuizService {
  Future<Map<String, String>> get _authHeaders async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> checkAnswer({
    required int quizId,
    required String answer,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.quizAnswer(quizId)),
        headers: await _authHeaders,
        body: jsonEncode({'answer': answer}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, ...data};
      }
      return {'success': false, 'message': data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal!'};
    }
  }
}
