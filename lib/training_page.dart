import 'package:flutter/material.dart';
import 'call_page.dart';

class TrainingPage extends StatelessWidget {
  const TrainingPage({super.key});

  void _goCall(BuildContext context, String scenario) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CallPage(scenario: scenario)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
                child: Row(
                  children: [
                    Text(
                      '통화훈련',
                      style: t.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    // IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
                  ],
                ),
              ),

              // 섹션 타이틀
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '통화 시나리오 선택',
                  style: t.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 시나리오 카드 4개
              _ScenarioTile(
                imagePath: 'assets/school.png',
                title: '학교',
                tag: 'school',
                subtitle: '학과사무실에서 학사일정을 문의하기 망설여 진다면?',
              ),
              const SizedBox(height: 20),
              _ScenarioTile(
                imagePath: 'assets/office.png',
                title: '직장',
                tag: 'work',
                subtitle: '직장에서 조리있고 간결하게 핵심만 대화하고 싶다면?',
              ),
              const SizedBox(height: 20),
              _ScenarioTile(
                imagePath: 'assets/cart.png',
                title: '주문',
                tag: 'order',
                subtitle: '빨리빨리 배달음식점에 조바심 내지않고 치킨을 시키고 싶다면?',
              ),
              const SizedBox(height: 20),
              _ScenarioTile(
                imagePath: 'assets/plane.png',
                title: '안부인사',
                tag: 'greeting',
                subtitle: '연락이 망설여지는 먼 지인에게 따뜻한 연락을 하고 싶다면?',
              ),
            ]
                .map((w) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: w,
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _ScenarioTile extends StatelessWidget {
  final String imagePath;
  final String title;
  final String tag;
  final String subtitle;

  const _ScenarioTile({
    super.key,
    required this.imagePath,
    required this.title,
    required this.tag,
    required this.subtitle
  });

  @override
  Widget build(BuildContext context) {
    void go() => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CallPage(scenario: tag)),
        );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: go,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 110, // 카드 높이
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              // PNG 아이콘
              Image.asset(imagePath, width: 55, height: 55, fit: BoxFit.contain),
              const SizedBox(width: 16),

              // 텍스트
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}
