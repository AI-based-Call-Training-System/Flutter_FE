// feedback_result_page.dart
import 'package:flutter/material.dart';
import 'feedback_detail_page.dart';

class FeedbackResultPage extends StatelessWidget {
  const FeedbackResultPage({super.key});

  Widget _buildScoreCard(String title, String score, String comment) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(score, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(comment)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(title: Text("최종결과"), backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/building.png', height: 100),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text("학과 사무실", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 20),
            _buildScoreCard("대화간극", "81%", "음음어체를 거의 안 썼어요! 상대방의 말을 자연스럽게 이어갔어요."),
            _buildScoreCard("목적달성", "100%", "최종적으로 장학금 정보를 알아냈어요! 장학금 마스터!"),
            _buildScoreCard("대화 속도", "77%", "말을 천천히 또박또박 말하려고 노력했어요. 끝까지 완주!"),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FeedbackDetailPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text("피드백 자세히보기"),
            ),
          ],
        ),
      ),
    );
  }
}
