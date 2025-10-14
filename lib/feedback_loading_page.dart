// feedback_loading_page.dart
import 'package:flutter/material.dart';
import 'feedback_result_page.dart';

class FeedbackLoadingPage extends StatefulWidget {
  const FeedbackLoadingPage({super.key});

  @override
  State<FeedbackLoadingPage> createState() => _FeedbackLoadingPageState();
}

class _FeedbackLoadingPageState extends State<FeedbackLoadingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 0.8).animate(_controller)
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const FeedbackResultPage(initialSessionId: "S-01K7G5NA7A3GJ3T0BB2BFAFX9Z"
            )),
          );
        }
      });
    _controller.forward();
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
