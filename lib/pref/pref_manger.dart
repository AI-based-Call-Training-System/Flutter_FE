
// jwt토큰 + id 저장용
// shared_preferences 패키지는 플러터앱에서 간단한 키-값의 영속저장을 도와주는 패키지로,
// 작고 단순 비민감 데이터를 기기에 영구 저장하고 읽어오는 용도의 라이브러리
import 'package:shared_preferences/shared_preferences.dart';
class PrefManager{
    // 저장
    static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
    }

    static Future<void> saveJWTtoken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    }


    // 불러오기
    static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id'); // 없으면 null
    }

    static Future<String?> getJWTtoken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // 없으면 null
    }

}