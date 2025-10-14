import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // origin/history에만 있었으나, 사용하지 않으므로 남겨둠
import 'dart:convert';


// userid 참조 매니져 (공통)
import '../pref/pref_manger.dart';
import '../services/restapi_service.dart'; // HEAD의 서비스 import 채택

// 색상 (공통)
const aiBubble   = Color(0xFFE8F8F5);   // AI 말풍선
const userBubble = Color(0xFFF3F5F8);   // 사용자 말풍선
const textMain   = Color(0xFF111214);
const textSub    = Color(0xFF9AA0A6);

// 공통 여백/치수 (공통)
const double kSidePad   = 16.0; // 화면과 말풍선 사이 동일 여백
const double kLogoH     = 16.0; // 로고 높이 (가로는 비율 유지)
const double kBubbleHP  = 14.0; // 말풍선 좌우 패딩
const double kBubbleVP  = 10.0; // 말풍선 상하 패딩
const double kRadius    = 12.0; // 말풍선 라운드

class FeedbackDetailPage extends StatefulWidget {
  final String initialSessionId;
  FeedbackDetailPage({Key? key,required this.initialSessionId}) : super(key: key);

  @override
  State<FeedbackDetailPage> createState() => _FeedbackDetailPageState();
}

class _FeedbackDetailPageState extends State<FeedbackDetailPage> {
  late String currentSessionId;
  List<FeedbackHistory> historyList = [];
  bool isLoading = true;
  String? userId;

  @override
  void initState() {
    super.initState();
    currentSessionId=widget.initialSessionId;
    _initUserAndFetchHistory();
  }
  
  Future<void> _initUserAndFetchHistory() async {
    String? id = await PrefManager.getUserId();
    // String? session = await PrefManager.getSessionId(); // HEAD의 sessionId 로직 유지
    if (!mounted) return;
    setState(() {
      userId = id ?? 'noUser';
    });

    // userId와 sessionId가 모두 null이 아닐 때 호출
    await fetchHistory(userId!, currentSessionId);
  }

  Future<void> fetchHistory(String userId, String sessionId) async { // HEAD의 함수 시그니처 채택
    try {
      List<dynamic> items = []; // 빈 List로 초기화

      // HEAD의 HistoryApiService 사용 로직 채택
      items = await HistoryApiService().getCurrnetHistory(sessionId); 
      // 시그니처: getCurrnetHistory(userId, sessionId) 사용

      if (mounted) {
        setState(() {
          historyList = items.map((item) => FeedbackHistory.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        print('기록 불러오기 실패');
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

  String _formatTime(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  // 말풍선 최대 폭 제한 (가독성) - origin/history 채택
  double _maxBubbleWidth(BuildContext context) =>
      MediaQuery.of(context).size.width * 0.78; // 약 78%

  // 말풍선 UI 구성 위젯 - origin/history의 디자인 및 레이아웃 로직 채택
  Widget _buildMessageItem(BuildContext context, FeedbackHistory item) {
    final isUser = item.role == 'user';
    final time = _formatTime(item.timestamp);

    if (isUser) {
      // ▶ 사용자(오른쪽)
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
                    padding: const EdgeInsets.symmetric(horizontal: kBubbleHP, vertical: kBubbleVP),
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
              padding: const EdgeInsets.only(right: 0),
              child: Text(time, style: const TextStyle(fontSize: 11, color: textSub)),
            ),
          ],
        ),
      );
    }

    // ▶ AI(왼쪽)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSidePad, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 로고
          Image.asset(
            'assets/logo_telpy.png',
            height: kLogoH,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _maxBubbleWidth(context)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: kBubbleHP, vertical: kBubbleVP),
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
                  itemBuilder: (context, i) => _buildMessageItem(context, historyList[i]),
                ),
    );
  }
}

// FeedbackHistory 모델 클래스 (공통)
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
