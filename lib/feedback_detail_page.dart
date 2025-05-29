import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FeedbackDetailPage extends StatefulWidget {
  const FeedbackDetailPage({super.key});

  @override
  State<FeedbackDetailPage> createState() => _FeedbackDetailPageState();
}

class _FeedbackDetailPageState extends State<FeedbackDetailPage> {
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/session/history?user_id=tester1'), // user_id 변경 가능
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        messages = List<Map<String, dynamic>>.from(jsonData['history']);
      });
    } else {
      print("❌ 히스토리 불러오기 실패: ${response.statusCode}");
    }
  }

  Widget _buildMessageBubble(String sender, String message, {bool isUser = false}) {
    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(maxWidth: 280),
          decoration: BoxDecoration(
            color: isUser ? Colors.green.shade100 : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: Radius.circular(isUser ? 12 : 0),
              bottomRight: Radius.circular(isUser ? 0 : 12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sender,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(message),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // 피드백 결과 페이지와 동일한 배경
      appBar: AppBar(
        title: const Text("학과 사무실에 장학금 문의"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("해당 통화에 대한 기록", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isUser = msg['role'] == 'user';
                  return _buildMessageBubble(
                    isUser ? "사용자" : "AI",
                    msg['content'] ?? '',
                    isUser: isUser,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
