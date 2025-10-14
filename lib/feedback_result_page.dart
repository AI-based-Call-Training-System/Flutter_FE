// feedback_result_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'feedback_detail_page.dart';
import 'services/restapi_service.dart'; // HEAD의 시스템 로직
import 'history_page.dart'; // origin/history의 UI 관련 import

// UI/레이아웃 상수
const lightColor = Color(0xFF80D9CD);
const pointColor = Color(0xFFFFE4D4);
const double kOuterGap = 24.0;
const double kRowGap = 20.0;
const double kCardHPad = 16.0;
const double kCardVPad = 14.0;

class FeedbackResultPage extends StatefulWidget {
  final String initialSessionId;
  const FeedbackResultPage({super.key, required this.initialSessionId});

  @override
  State<FeedbackResultPage> createState() => _FeedbackResultPageState();
}

class _FeedbackResultPageState extends State<FeedbackResultPage> {
  late Future<Map<String, dynamic>> _futureFeedback;
  late String currentSessionId;

  @override
  void initState() {
    super.initState();
    currentSessionId = widget.initialSessionId;
    _futureFeedback = fetchFeedbackResult();
  }

  Future<Map<String, dynamic>> fetchFeedbackResult() async {
    try {
      final service = FeedbackApiService();
      final response = await service.getFeedback(currentSessionId);
      return response;
    } catch (e) {
      throw Exception('피드백 결과를 불러오지 못했습니다: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '통화훈련 피드백',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111214),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureFeedback,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('에러 발생: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('데이터가 없습니다.'));
          }

          final data = snapshot.data!;
          final List<Map<String, dynamic>> scores =
              List<Map<String, dynamic>>.from(data['scores'] ?? []);

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, kOuterGap, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = scores[index];
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: index == scores.length - 1 ? 0 : kRowGap),
                        child: _ScoreRow(
                          title: item['title'] ?? '점수 항목',
                          points: item['score'] ?? 0,
                          comment: item['comment'] ?? '피드백 코멘트가 없습니다.',
                        ),
                      );
                    },
                    childCount: scores.length,
                  ),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    kOuterGap + MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    children: [
                      const Spacer(),
                      _BottomCTA(sessionId: currentSessionId),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// --- UI 컴포넌트 정의 ---

class _BottomCTA extends StatelessWidget {
  final String sessionId;
  const _BottomCTA({required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FeedbackDetailPage(initialSessionId: sessionId),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: pointColor,
          foregroundColor: const Color(0xFF111214),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          '통화 기록 확인',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String title;
  final int points;
  final String comment;

  const _ScoreRow({
    required this.title,
    required this.points,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (points.clamp(0, 25)) / 25.0;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: kCardHPad, vertical: kCardVPad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 148,
            height: 110,
            child: CustomPaint(
              painter: _SemiGaugePainter(percent: percent),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$points점',
                      style: const TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              comment,
              style: const TextStyle(
                fontSize: 14.5,
                color: Color(0xFF222222),
                height: 1.55,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SemiGaugePainter extends CustomPainter {
  final double percent;

  _SemiGaugePainter({required this.percent});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 10.0;
    final center = Offset(size.width / 2, size.height - stroke / 2);
    final radius = (size.height - stroke) * 0.9;
    final safeRadius = radius > size.width / 2 ? size.width / 2 - 2 : radius;
    final rect = Rect.fromCircle(center: center, radius: safeRadius);

    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        begin: Alignment(-0.8, 0.4),
        end: Alignment(0.8, 1.0),
        colors: [Color(0xFFE6FFFA), Color(0xFFBFF2EB)],
      ).createShader(rect);

    final fgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        begin: Alignment(-0.2, 0.2),
        end: Alignment(0.8, 1.0),
        colors: [lightColor, Color(0xFF00C4AA)],
      ).createShader(rect);

    const start = 3.141592653589793;
    const sweep = 3.141592653589793;

    canvas.drawArc(rect, start, sweep, false, bgPaint);
    canvas.drawArc(rect, start, sweep * percent, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant _SemiGaugePainter old) =>
      old.percent != percent;
}
