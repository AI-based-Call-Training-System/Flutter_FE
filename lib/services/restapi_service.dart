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

// 세션 관리 api
class SessionApiService{
  final String baseUrl = '$BASE_URL/history'; 
  String session="";
  String scenario="";
  //세션 획득
  // !!! 만약 여기 페이지를 나갔다가 다시 들어오면 세션은 재발급 되어 벌임
  // 1. 대화한 상태에서 갱신 2. 대화를 아직 안한 상태에서 갱신
  // 이 로직을 생각해서 설계해보면 좋을 듯

  Future<String?> getSession(String? id,String? scenario) async{
    if (id==null) {
      print("id가 정상적으로 들어오지 않았습니다");  
      return null;
    }
    
    /////////======풀지 못한 문제: session이 이 페이지 새로 올때마다 db에 써지는가?
    // // 1. 로컬에 저장된 기존 세션 ID가 있는지 확인
    // String? existingSession = await PrefManager.getSessionId();
    
    // // 💡 기존 세션이 있다면 그것을 반환하고 서버 호출을 건너뜁니다.
    // //    (대화 기록을 이어서 사용하려는 경우)
    // if (existingSession != null && existingSession.isNotEmpty) {
    //     print("✅ 로컬에서 기존 세션 ID 재사용: $existingSession");
    //     return existingSession;
    // }

    // // 2. 기존 세션이 없으면 (새 대화 시작) 서버에 새 세션 발급 요청
    
    
    
    String? jwtToken=await PrefManager.getJWTtoken();
    print("원래 토큰: $jwtToken");
    Map<String, String> title = {
      'order': '주문',
      'school': '학교',
      'greeting':'안부인사',
      'work':'직장'
    };    
    //서버에 부쳐서 세션을 획득
    // 이때 서버에 senario-> title 도 저장할 거임
    final response = await http.post(
      Uri.parse('$baseUrl/$id/sessions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonEncode({
        'tags': scenario,
        'title':title[scenario],
      }),
      
    );
    if (response.statusCode == 201) {
      var data = json.decode(response.body);
      session = data['item']['sessionId']; // JSON에서 꺼내기
      print("서버에서 갓 가져온 세션: $session");
      // 세션 저장
      await PrefManager.saveSessionId(session);
      return session;
    } else {
      print("${scenario} ${title[scenario]}");
      print("getSession api 실패: ${response.statusCode} / ${response.body}");
      return null;
    }

  }
  // //선택 시나리오 저장
  // Future<void> setScenario(String? scenario) async {
  //   this.scenario=scenario;
  // }
  // //선택 시나리오 가져오기
  // Future<String?> getScenario() async{
  //   if(scenario==""){
  //     return "noscenario";
  //     }
  //   return scenario;
  // }
}

// ai 대화시 api
class CallApiService{

    // 사용자 음성 백엔드 전송 함수
  Future<Map<String, dynamic>> sendUserAudio(String userId, String token, Uint8List bytes,String sessionId,String scenario) async {
    
    try {
      var request = http.MultipartRequest(
        'POST',
        
        Uri.parse('http://localhost:8000/chat/audio'),
      );
      print("chat/audio에서 토큰: $token");

      // request.headers['Authorization'] = 'Bearer $token';

      //아래줄 널값처리 안하면 에러남
      request.fields['user_id'] = userId; //?? 'noID'; // null이면 빈 문자열
      request.fields['session_id']=sessionId;//??'noSessionId';
      request.fields['scenario']=scenario;//??'noSessionId';
      request.fields['token']=token;//??'noSessionId';

      
    
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

//대화 가져올 때 쓰는거
class HistoryApiService{
    // 가장 최근의 대화
    Future<List<dynamic>> 
    getCurrnetHistory(String sessionId) async {

    String? jwtToken=await PrefManager.getJWTtoken();
    String? userId=await PrefManager.getUserId();
    // String? sessionId=await PrefManager.getSessionId();

    try{
      final response = await http.get(
        Uri.parse('http://localhost:3000/history/$userId/$sessionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );
      // print('Response Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');

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

class FeedbackApiService{

    Future<Map<String, dynamic>> getFeedback(String sessionId) async {

    // String? sessionId=await PrefManager.getSessionId();
    final response = await http.get(
      Uri.parse('http://localhost:8000/evaluate_audio/$sessionId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('피드백 결과를 불러오지 못했습니다.');
    }
  
    }}
