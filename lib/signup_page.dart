import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'login_page.dart';
import 'main.dart'; // 로그인 페이지를 연결하기 위해 import

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> signUp(String name, String email, String password) async {
    final url = Uri.parse('https://your-api-url.com/signup'); // 회원가입 API 엔드포인트
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      // 회원가입 성공 -> 로그인 페이지로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      // 회원가입 실패 -> 에러 메시지 표시
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("회원가입 실패"),
          content: Text("회원가입 정보를 확인해주세요."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("확인"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 👈 배경 흰색
      appBar: AppBar(
        title: Text('회원가입'),
        backgroundColor: Colors.white, // 👈 앱바 흰색
        elevation: 0, // 👈 그림자 제거
        iconTheme: IconThemeData(color: Colors.black), // 👈 아이콘 색 변경
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '회원가입을 해주세요!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              Text("이름"),
              SizedBox(height: 5),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: '이름을 입력해주세요',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Text("이메일"),
              SizedBox(height: 5),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: '이메일을 입력해주세요',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Text("비밀번호"),
              SizedBox(height: 5),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '비밀번호를 입력해주세요',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Text("비밀번호 확인"),
              SizedBox(height: 5),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '비밀번호를 다시 입력해주세요',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_passwordController.text != _confirmPasswordController.text) {
                        // 비밀번호 확인이 일치하지 않으면 경고 메시지 표시
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("오류"),
                            content: Text("비밀번호가 일치하지 않습니다."),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text("확인"),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // 회원가입 요청
                        signUp(
                          _nameController.text,
                          _emailController.text,
                          _passwordController.text,
                        );
                      }
                    }
                  },
                  child: Text(
                    '회원가입 하기',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
