import 'package:flutter/material.dart';
import 'home_page.dart';
import 'my_page.dart';
import 'training_page.dart';
import 'history_page.dart'; // 히스토리 페이지
import 'feedback_result_page.dart'; // 피드백결과 페이지


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  final _pages = const [
    HomePage(),        // 홈
    TrainingPage(),    // 통화훈련
    HistoryPage(),     // 히스토리
    MyPageScreen(),    // MY
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 88,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2)),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              currentIndex: _index,
              onTap: (i) => setState(() => _index = i),
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.black38,

              iconSize: 28,
              selectedFontSize: 14,
              unselectedFontSize: 12,

              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined), 
                  activeIcon: Icon(Icons.home), 
                  label: '홈'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.call_outlined), 
                  activeIcon: Icon(Icons.call), 
                  label: '통화훈련'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history), 
                  activeIcon: Icon(Icons.history_edu), 
                  label: '히스토리'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline), 
                  activeIcon: Icon(Icons.person), 
                  label: 'MY'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
