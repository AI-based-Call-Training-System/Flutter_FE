import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';  // 추가
import 'dart:typed_data'; // Uint8List 사용시 필요


// userid 참조용
import '../pref/pref_manger.dart';
import 'dart:html' as html;

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
        'id': userId,

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
      print("서버에서 갓 가져온 세션: $session");
      await PrefManager.saveSessionId(session);
      return session;
    } else {
      print("getSession api 실패: ${response.statusCode} / ${response.body}");
      return null;
    }

  }
}

class CallApiService{

    // 사용자 음성 백엔드 전송 함수
  Future<Map<String, dynamic>> sendUserAudio(String userId, String token, Uint8List bytes,String sessionId) async {
    
    try {
      var request = http.MultipartRequest(
        'POST',
        
        Uri.parse('http://localhost:8000/chat/audio'),
      );

      //아래줄 널값처리 안하면 에러남
      request.fields['user_id'] = userId; //?? 'noID'; // null이면 빈 문자열
      request.fields['session_id']=sessionId;//??'noSessionId';
      request.fields['token']=token;//대화 내용 추가할 때 필요한 토큰 추가

    
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'recorded_audio.webm',
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      return json.decode(response.body) as Map<String, dynamic>;



    } catch (e) {
      print("sendUserAudioException 발생: $e");
      return {"error": e.toString()};
    }
  }
}

class HistoryApiService{
    Future<List<dynamic>> getCurrnetHistory() async {

    String? jwtToken=await PrefManager.getJWTtoken();
    String? userId=await PrefManager.getUserId();
    String? sessionId=await PrefManager.getSessionId();

    try{
      final response = await http.get(
        Uri.parse('http://localhost:3000/history/$userId/$sessionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );
      print("이상하네: $jwtToken");
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<dynamic> history = data['items']; // JSON에서 꺼내기
        return history;
      } else {
        print("getCurrnetHistory api 실패: ${response.statusCode} / ${response.body}");
        return [{
          "status": "200",
          "message": "restapi service history api"
        }];
      }}
      catch(e){
        print(" 좀 이상한 듯");
        return [{
          "status": "200",
          "message": "restapi service history api"
        }];
      }

  }
}