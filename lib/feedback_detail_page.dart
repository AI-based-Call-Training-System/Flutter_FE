import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FeedbackDetailPage extends StatefulWidget {
  const FeedbackDetailPage({Key? key}) : super(key: key);

  @override
  _FeedbackDetailPageState createState() => _FeedbackDetailPageState();
}

class _FeedbackDetailPageState extends State<FeedbackDetailPage> {
  List<FeedbackHistory> historyList = [];
  bool isLoading = true;

  final String userId = "tester1"; // 🔒 userId 고정

  @override
  void initState() {
    super.initState();
    fetchHistory(userId);
  }

  Future<void> fetchHistory(String userId) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/session/history?user_id=tester1'), // ← 서버 주소 수정 필요
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> history = data['history'];

      setState(() {
        historyList = history.map((item) => FeedbackHistory.fromJson(item)).toList();
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load history');
    }
  }

  Widget _buildMessageItem(FeedbackHistory history) {
    bool isUser = history.role == "user";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser ? Colors.green.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              history.content,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            history.timestamp,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Feedback Detail'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : historyList.isEmpty
          ? const Center(child: Text('히스토리가 없습니다.'))
          : ListView.builder(
        itemCount: historyList.length,
        itemBuilder: (context, index) {
          return _buildMessageItem(historyList[index]);
        },
      ),
    );
  }
}

class FeedbackHistory {
  final String role;
  final String content;
  final String timestamp;
  final String audioPath;

  FeedbackHistory({
    required this.role,
    required this.content,
    required this.timestamp,
    required this.audioPath,
  });

  factory FeedbackHistory.fromJson(Map<String, dynamic> json) {
    return FeedbackHistory(
      role: json['role'] ?? '',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] ?? '',
      audioPath: json['audio_path'] ?? '',
    );
  }
}