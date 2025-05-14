import 'package:flutter/material.dart';
import 'call_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void navigateToCallPage(BuildContext context, String scenario) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallPage(scenario: scenario),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ 전체 배경 흰색
      body: Column(
        children: [
          // ✅ 상단 배너
          Image.asset(
            'assets/home_nav.png',
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          // ✅ 검색창
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: '궁금한 내용을 입력해보세요',
                suffixIcon: Icon(Icons.search),

                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ✅ 통화 시나리오 4개
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              childAspectRatio: 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildScenarioCard(context, '학교', Icons.school),
                _buildScenarioCard(context, '직장', Icons.apartment),
                _buildScenarioCard(context, '안부인사', Icons.send),
                _buildScenarioCard(context, '주문', Icons.assignment),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: 0,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: '기록'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이'),
        ],
      ),
    );
  }

  Widget _buildScenarioCard(BuildContext context, String title, IconData icon) {
    return GestureDetector(
      onTap: () => navigateToCallPage(context, title),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(1, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.grey.shade700),
            SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
