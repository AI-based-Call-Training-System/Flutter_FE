import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://10.0.2.2:3000/auth';

  // 회원가입
  Future<bool> signup(String phone, String password, String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phoneNumber': phone,
        'password': password,
        'id': name,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print("회원가입 실패: ${response.statusCode} / ${response.body}");
      return false;
    }
  }

  // 로그인
  Future<bool> login(String id, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': id,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("로그인 실패: ${response.statusCode} / ${response.body}");
      return false;
    }
  }
}
