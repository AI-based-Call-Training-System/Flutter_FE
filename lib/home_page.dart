import 'package:flutter/material.dart';
import 'call_page.dart';
import 'main_navi.dart';
import 'feedback_result_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static const double side = 20;

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
          padding: const EdgeInsets.only(bottom: 24), // 하단 네비 여유
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 상단 로고
              Padding(
                padding: const EdgeInsets.fromLTRB(side, 28, side, 20),
                child: Row(
                  children: [
                    // assets에 넣어둔 새 로고
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

              // 전화 예절
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('전화 예절',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _EtiquetteCard(
                        title: '예절1',
                        icon: Icons.phone,
                        background: const Color(0xFFFFE8D6),
                        onTap: () => _goCall(context, '예절1'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _EtiquetteCard(
                        title: '예절2',
                        icon: Icons.list_alt,
                        background: const Color(0xFFE7F0FF),
                        onTap: () => _goCall(context, '예절2'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 최근 활동
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('최근 활동',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
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

class _EtiquetteCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color background;
  final VoidCallback onTap;
  const _EtiquetteCard({
    required this.title,
    required this.icon,
    required this.background,
    required this.onTap,
  });

  @override //예절카드
  Widget build(BuildContext context) {
    return Material(
      // color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 150,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              Icon(icon, size: 26, color: Colors.black54),
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

  @override // 최근활동
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
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(fontSize: 12, color: Colors.black54),
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
