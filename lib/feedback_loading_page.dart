// feedback_loading_page.dart
import 'package:flutter/material.dart';
import 'feedback_result_page.dart';
import 'pref/pref_manger.dart';

class FeedbackLoadingPage extends StatefulWidget {
  const FeedbackLoadingPage({super.key});

  @override
  State<FeedbackLoadingPage> createState() => _FeedbackLoadingPageState();
}

class _FeedbackLoadingPageState extends State<FeedbackLoadingPage>
  with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String? sessionId;


  @override
 void initState() {
  super.initState();
  _controller = AnimationController(
    duration: const Duration(seconds: 3),
    vsync: this,
  );
  _animation = Tween<double>(begin: 0, end: 0.8).animate(_controller)
    ..addListener(() => setState(() {}));

  // 애니메이션과 세션 로딩 동시에 처리
  _startLoading();
}

Future<void> _startLoading() async {
  // 세션 아이디 로딩
  final loadedSessionId = await PrefManager.getSessionId();

  // 애니메이션 시작
  await _controller.forward();

  if (!mounted) return;

  // 애니메이션 완료 후 화면 이동
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => FeedbackResultPage(
        initialSessionId: loadedSessionId ?? 'noUser',
        needEval: false,
      ),
    ),
  );
}


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int percent = (_animation.value * 100).toInt();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("$percent%...analyzing...", style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            Container(
              width: 250,
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.grey.shade300,
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: _animation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFa8e063), Color(0xFF56ab2f)],
                        ),
                      ),
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
