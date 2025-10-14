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
                subtitle: '기초, 초급1, 초급2, 중급2 한국어 교실 모집',
              ),
              const SizedBox(height: 20),
              _ScenarioTile(
                imagePath: 'assets/office.png',
                title: '직장',
                subtitle: '기초, 초급1, 초급2, 중급2 한국어 교실 모집',
              ),
              const SizedBox(height: 20),
              _ScenarioTile(
                imagePath: 'assets/cart.png',
                title: '주문',
                subtitle: '이주배경 청소년의 진로성장지원프로그램',
              ),
              const SizedBox(height: 20),
              _ScenarioTile(
                imagePath: 'assets/plane.png',
                title: '안부인사',
                subtitle: '외국인주민에게 직접 배우는 무료 교육',
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
  final String subtitle;

  const _ScenarioTile({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    void go() => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CallPage(scenario: title)),
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
