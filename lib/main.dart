import 'package:flutter/material.dart';
import 'login_page.dart'; // 로그인 페이지 import
import 'signup_page.dart'; // 회원가입 페이지 import
import 'main_navi.dart';
import 'history_page.dart'; // 히스토리 페이지
import 'feedback_result_page.dart'; // 피드백결과 페이지

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        fontFamily: 'NotoSansKR',  
        useMaterial3: false,
      ),

      // history 리스트 -> feedback_result_page.dart로 전환
      routes: {
        '/feedbackResult': (context) => FeedbackResultPage(initialSessionId: "S-01K7G5NA7A3GJ3T0BB2BFAFX9Z"),
      },

      home: SplashScreen(), // 첫 화면을 스플래시 화면으로 설정
    );
  }
}

// ✅ 스플래시 화면: 버튼을 눌러야 이동
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/call_image.png',
              width: 80,
              height: 80,
            ),
            SizedBox(height: 20),
            Text(
              '편지보단 메신저, 메신저보단 전화!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              '지금 상황을 선택하고 시작해보세요!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 30),
            // ✅ "시작하기" 버튼 → 회원가입 페이지로 이동
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()), // 회원가입 페이지로 이동
                );
              },
              child: Text('시작하기'),
            ),
            SizedBox(height: 20),
            // ✅ "이미 계정이 있나요? 로그인" → 로그인 페이지로 이동
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()), // 로그인 페이지로 이동
                );
              },
              child: Text.rich(
                TextSpan(
                  text: '이미 계정이 있나요? ',
                  style: TextStyle(color: Colors.grey),
                  children: <TextSpan>[
                    TextSpan(
                      text: '로그인',
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
