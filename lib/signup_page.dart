import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'login_page.dart';
import '../services/restapi_service.dart'; // API 연동
import '../services/config.dart'; // BASE_URL 정의

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();

  bool _isLoading = false;

  void _signup() async {
    print("회원가입 시작");
    
    final isDuplicate = await ApiService().checkDuplicateId(_idController.text.trim());
    if (isDuplicate) {
      _showErrorDialog("중복된 아이디", "이미 사용 중인 아이디입니다.");
      return;
    }
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);

    final success = await ApiService().signup(
      phone,
      password,
      _nameController.text.trim(),
      _idController.text.trim()
    );

    //setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      _showErrorDialog("회원가입 실패", "전화번호 또는 비밀번호를 다시 확인해주세요.");
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("확인"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('회원가입'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
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
              Text("아이디"),
              SizedBox(height: 5),
              TextFormField(
                controller: _idController,
                decoration: InputDecoration(
                  hintText: '아이디를 입력해주세요',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return '아이디를 입력해주세요';
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text("전화번호"),
              SizedBox(height: 5),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  hintText: '전화번호를 입력해주세요',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
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
                        _showErrorDialog("오류", "비밀번호가 일치하지 않습니다.");
                      } else {
                        // ✅ 여기 바로 아래에 비밀번호 형식 검사 추가!
                        final password = _passwordController.text.trim();
                        if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$').hasMatch(password)) {
                          _showErrorDialog("비밀번호 오류", "비밀번호는 영문+숫자 포함 8자 이상이어야 합니다.");
                          return;
                        }

                        _signup(); // 최종 가입 실행
                      }
                    }
                  },
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
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