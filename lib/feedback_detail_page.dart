import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// 색상
const aiBubble   = Color(0xFFE8F8F5);   // AI 말풍선
const userBubble = Color(0xFFF3F5F8);   // 사용자 말풍선
const textMain   = Color(0xFF111214);
const textSub    = Color(0xFF9AA0A6);

// 공통 여백/치수
const double kSidePad   = 16.0; // 화면과 말풍선 사이 동일 여백
const double kLogoH     = 16.0; // 로고 높이 (가로는 비율 유지)
const double kBubbleHP  = 14.0; // 말풍선 좌우 패딩
const double kBubbleVP  = 10.0; // 말풍선 상하 패딩
const double kRadius    = 12.0; // 말풍선 라운드

class FeedbackDetailPage extends StatefulWidget {
  const FeedbackDetailPage({Key? key}) : super(key: key);

  @override
  State<FeedbackDetailPage> createState() => _FeedbackDetailPageState();
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
    final url = Uri.parse('http://localhost:8000/session/history?user_id=$userId');
    try {
      final response = await http.get(url);
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> history = data['history'] ?? [];
        setState(() {
          historyList = history.map((e) => FeedbackHistory.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String _formatTime(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  // 말풍선 최대 폭 제한 (가독성)
  double _maxBubbleWidth(BuildContext context) =>
      MediaQuery.of(context).size.width * 0.78; // 약 78%

  Widget _buildMessageItem(BuildContext context, FeedbackHistory item) {
    final isUser = item.role == 'user';
    final time = _formatTime(item.timestamp);

    if (isUser) {
      // ▶ 사용자(오른쪽) — 오른쪽 여백 = kSidePad
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: kSidePad, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                const Spacer(),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: _maxBubbleWidth(context)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: kBubbleHP, vertical: kBubbleVP),
                    decoration: BoxDecoration(
                      color: userBubble,
                      borderRadius: BorderRadius.circular(kRadius),
                    ),
                    child: Text(
                      item.content,
                      style: const TextStyle(
                        fontSize: 15.5,
                        color: textMain,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(right: 0), // 이미 kSidePad로 감싸져 있음
              child:
                  Text(time, style: const TextStyle(fontSize: 11, color: textSub)),
            ),
          ],
        ),
      );
    }

    // ▶ AI(왼쪽) — 로고는 윗줄, 말풍선은 로고와 무관하게 화면 왼쪽 여백 kSidePad부터 시작
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSidePad, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 로고만 (크롭 없이 그대로)
          Image.asset(
            'assets/logo_telpy.png',
            height: kLogoH,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _maxBubbleWidth(context)),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: kBubbleHP, vertical: kBubbleVP),
              decoration: BoxDecoration(
                color: aiBubble,
                borderRadius: BorderRadius.circular(kRadius),
              ),
              child: Text(
                item.content,
                style: const TextStyle(
                  fontSize: 15.5,
                  color: textMain,
                  height: 1.45,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(time, style: const TextStyle(fontSize: 11, color: textSub)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 전체 흰색 + AppBar도 흰색, 그림자 제거
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '통화기록',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        foregroundColor: textMain,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, size: 26),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            tooltip: '홈으로',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : historyList.isEmpty
              ? const Center(child: Text('히스토리가 없습니다.'))
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  itemCount: historyList.length,
                  itemBuilder: (context, i) =>
                      _buildMessageItem(context, historyList[i]),
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
