import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'services/config.dart';

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
    final url = Uri.parse('http://localhost:3000/session/history?user_id=$userId');
    print('Requesting URL: $url');

    try {
      final response = await http.get(url);

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> history = data['history'];

        if (mounted) {
          setState(() {
            historyList = history.map((item) => FeedbackHistory.fromJson(item)).toList();
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        print('Failed to load history with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
              // ✨ 변경된 부분: 말풍선 색상 및 그림자 효과
              color: isUser ? Colors.green[200] : Colors.white,

              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              history.content,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            history.timestamp, // 실제 앱에서는 타임스탬프 포맷을 변경하는 것이 좋습니다.
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✨ 변경된 부분: 배경색
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Feedback Detail'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : historyList.isEmpty
              ? const Center(child: Text('히스토리가 없습니다.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
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