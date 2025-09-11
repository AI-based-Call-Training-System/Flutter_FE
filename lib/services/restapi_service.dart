import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';  // 추가

// userid 참조용
import '../pref/pref_manger.dart';

class ApiService {
  final String baseUrl = '$BASE_URL/auth'; 

  // 회원가입
  Future<bool> signup(String phone, String password, String name, String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phoneNumber': phone,
        'password': password,

        'name': name,
        'userId': userId,

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

    if (response.statusCode == 201) {
      var data = json.decode(response.body);
      String token = data['access_token']; // JSON에서 꺼내기
      await PrefManager.saveJWTtoken(token);

      await PrefManager.saveUserId(id);

      return true;
    } else {
      print("로그인 실패: ${response.statusCode} / ${response.body}");
      return false;
    }
  }

  Future<bool> checkDuplicateId(String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/check-id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );

    if (response.statusCode == 409) {
      return true; // 중복됨
    } else if (response.statusCode == 200) {
      return false; // 사용 가능
    } else {
      print("아이디 중복 확인 실패: ${response.statusCode}");
      return false;
    }
  }

}

class SessionApiService{
  final String baseUrl = '$BASE_URL/history'; 
  //세션 획득
  Future<String?> getSession(String? id) async{
    if (id==null) {
      print("id가 정상적으로 들어오지 않았습니다");  
      return null;
    }

    String? jwtToken=await PrefManager.getJWTtoken();
    print(jwtToken);

    final response = await http.post(
      Uri.parse('$baseUrl/$id/sessions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
    );
    if (response.statusCode == 201) {
      var data = json.decode(response.body);
      String session = data['item']['sessionId']; // JSON에서 꺼내기
      await PrefManager.saveSession(session);
      return session;
    } else {
      print("getSession api 실패: ${response.statusCode} / ${response.body}");
      return null;
    }

  }
}
