// feedback_result_page.dart
import 'package:flutter/material.dart';
import 'feedback_detail_page.dart';
import 'history_page.dart';

const lightColor = Color(0xFF80D9CD);
const pointColor = Color(0xFFFFE4D4);

// 레이아웃 공통 여백
const double kOuterGap = 24.0;      // 헤더 아래, 화면 맨 아래 여백
const double kRowGap   = 20.0;      // 게이지 박스 사이 간격
const double kCardHPad = 16.0;      // 카드 내부 좌우 패딩
const double kCardVPad = 14.0;      // 카드 내부 상하 패딩

class FeedbackResultPage extends StatelessWidget {
  const FeedbackResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 전체 흰색
      appBar: AppBar(
        title: const Text(
          '통화훈련 피드백', // ← 제목 변경
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

      // ▼ 버튼을 '게이지 묶음 ~ 화면 바닥' 영역의 정중앙에 놓기
      body: CustomScrollView(
        slivers: [
          // 게이지 카드들
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, kOuterGap, 20, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(const [
                _ScoreRow(
                  title: '문맥평가',
                  points: 25,
                  comment: '대화가 시나리오와 전혀 맞지 않아 주제에서 크게 벗어났습니다.',
                ),
                SizedBox(height: kRowGap),
                _ScoreRow(
                  title: '발화속도',
                  points: 25,
                  comment: '대화가 시나리오와 전혀 맞지 않음. 주제에서 크게 벗어났습니다.',
                ),
                SizedBox(height: kRowGap),
                _ScoreRow(
                  title: '목적달성',
                  points: 25,
                  comment: '대화 목적을 달성하지 못했습니다. 주문해야 할 핵심 내용이 빠져 있습니다.',
                ),
                SizedBox(height: kRowGap),
                _ScoreRow(
                  title: '대화간격',
                  points: 25,
                  comment: '대화가 시나리오와 전혀 맞지 않아 주제에서 크게 벗어났습니다.',
                ),
              ]),
            ),
          ),

          // 남은 공간 채우기 + 중앙 정렬 버튼
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                kOuterGap + MediaQuery.of(context).padding.bottom,
              ),
              child: const Column(
                children: [
                  Spacer(),
                  _BottomCTA(),   // ▶ 여기 때문에 에러났던 부분 — 위젯 정의 추가됨
                  Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 하단 CTA 버튼 (독립 위젯)
class _BottomCTA extends StatelessWidget {
  const _BottomCTA();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FeedbackDetailPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: pointColor,
          foregroundColor: const Color(0xFF111214),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          '통화 기록 확인',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// 반원 게이지 + 오른쪽 피드백 문장
class _ScoreRow extends StatelessWidget {
  final String title;
  final int points; // 0~25
  final String comment;

  const _ScoreRow({
    required this.title,
    required this.points,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (points.clamp(0, 25)) / 25.0; // 0~1

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kCardHPad, vertical: kCardVPad),
      decoration: BoxDecoration(
        color: Colors.white, // 카드 내부색 (외곽선 없음)
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

/// 반원 게이지: 완전한 '원'의 반원으로 보이도록(찌그러짐 방지)
class _SemiGaugePainter extends CustomPainter {
  final double percent; // 0~1

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

    const start = 3.141592653589793; // pi
    const sweep = 3.141592653589793; // pi

    canvas.drawArc(rect, start, sweep, false, bgPaint);
    canvas.drawArc(rect, start, sweep * percent, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant _SemiGaugePainter old) => old.percent != percent;
}
