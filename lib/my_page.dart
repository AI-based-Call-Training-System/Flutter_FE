// lib/mypage.dart
import 'package:flutter/material.dart';
import './pref/pref_manger.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({
    super.key,
    this.userId = '유저 아이디',
    this.phone = '전화번호',
  });

  final String userId;
  final String phone;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 16, 12),
              child: Row(
                children: [
                  Text(
                    '마이페이지',
                    style: t.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // 🔽 구분선
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFE8ECF1),
              ),
            ),
            const SizedBox(height: 20),

            // 스크롤 가능 영역
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 섹션: 내 프로필
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Text(
                        '내 프로필',
                        style: t.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 18),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 26,
                                backgroundColor: Color(0xFFE9F3FF),
                                child: Icon(Icons.person,
                                    size: 28, color: Color(0xFF4A90E2)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userId,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      phone,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // 섹션: 내 계정
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Text(
                        '내 계정',
                        style: t.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const _SettingTile(title: '도움말'),
                          const SizedBox(height: 12),
                          _SettingTile(
                            title: '로그아웃',
                            onTap: () => _confirmLogout(context),
                          ),
                          const SizedBox(height: 12),
                          const _SettingTile(title: '계정 탈퇴', destructive: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🔽 하단 로고 & 설명 (박스 X, 화면 맨 끝)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/logo_telpy.png',
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'AI 기반 통화 훈련 시스템',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9AA3AF),
                      height: 1.3,
                    ),
                  ),
                  const Text(
                    '소프트웨어학부 강은혜, 이수민, 정윤민  ·  v1.0.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9AA3AF),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 로그아웃 확인 팝업
Future<void> _confirmLogout(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('로그아웃'),
      content: const Text('로그아웃 하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('아니오'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('예'),
        ),
      ],
    ),
  );

  if (result == true) {
    await PrefManager.saveJWTtoken('');
    await PrefManager.saveSessionId('');
    await PrefManager.saveUserId('');
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }
}

// 내부 위젯
class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.title,
    this.onTap,
    this.destructive = false,
  });

  final String title;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color =
        destructive ? Colors.redAccent : Colors.black.withOpacity(0.85);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
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
