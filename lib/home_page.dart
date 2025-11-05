import 'dart:math';
import 'package:flutter/material.dart';
import 'call_page.dart';
import 'main_navi.dart';
import 'feedback_result_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const double side = 20;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 전화 예절 문구 목록
  static const List<String> etiquetteTips = [
    '용건을 미리 정리해\n 짧은 통화가 되게 한다.',
    '늦은 밤, 이른 아침, \n식사시간은 가급적 피한다.',
    '잘못 걸렸다면 정중히 사과하고 \n통화를 마무리한다.',
    '통화가 연결되면 인사하고\n자신을 소개한다.',
    '상이 이쪽을 알아차리면 \n먼저 인사하고 용건을 말한다.',
    '상대가 없으면 정중히 부탁하고 \n용건을 전한다.',
    '상대방과 통화 후 \n먼저 끊은 것을 확인한 후에\n끊는다.',
  ];

  late String todayTip;

  @override
  void initState() {
    super.initState();
    // 홈 화면 진입 시 랜덤 팁 1개 선택
    todayTip = etiquetteTips[Random().nextInt(etiquetteTips.length)];
  }

  void _goCall(BuildContext context, String scenario) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CallPage(scenario: scenario)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 로고
              Padding(
                padding: const EdgeInsets.fromLTRB(HomePage.side, 28, HomePage.side, 20),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/logo_telpy.png',
                      height: 38,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
              // 배너
              AspectRatio(
                aspectRatio: 375 / 178,
                child: Image.asset('assets/home_nav.png', fit: BoxFit.cover),
              ),
              const SizedBox(height: 24),

              // 전화 예절 (단일 카드 + 랜덤 문구)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '오늘의 전화 예절',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _TodayEtiquetteCard(
                  tip: todayTip,
                  onTap: () => _goCall(context, '전화예절'),
                ),
              ),
              const SizedBox(height: 20),

              // 최근 활동
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '최근 활동',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _RecentTile(
                      leadingIcon: Icons.assignment_outlined,
                      title: '주문1',
                      subtitle: '빨리빨리 배달음식점에 조바심 내지않고 치킨을 시키고 싶다면?',
                    ),
                    SizedBox(height: 10),
                    _RecentTile(
                      leadingIcon: Icons.shopping_cart_outlined,
                      title: '주문2',
                      subtitle: '빨리빨리 배달음식점에 조바심 내지않고 치킨을 시키고 싶다면?',
                    ),
                    SizedBox(height: 10),
                    _RecentTile(
                      leadingIcon: Icons.airplanemode_active_outlined,
                      title: '안부인사',
                      subtitle: '연락이 망설여지는 먼 지인에게 따뜻한 연락을 하고 싶다면?',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayEtiquetteCard extends StatelessWidget {
  final String tip;
  final VoidCallback onTap;

  const _TodayEtiquetteCard({
    required this.tip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x80D9CD).withOpacity(0.35), 
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 140, // 
          width: double.infinity,
          padding: const EdgeInsets.all(20), 
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 왼쪽: 텍스트 영역
              Expanded(
                child: Text(
                  tip,
                  textAlign:TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // 오른쪽: 이미지 (assets/call_man.png)
              Image.asset(
                'assets/call_man.png',
                width: 80, 
                height: 80,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _RecentTile extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final String subtitle;
  const _RecentTile({
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(leadingIcon, size: 24, color: Colors.black87),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black38),
        ],
      ),
    );
  }
}
