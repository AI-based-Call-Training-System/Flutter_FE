import 'package:flutter/material.dart';

class CallPage extends StatelessWidget {
  final String scenario;

  CallPage({required this.scenario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ✅ 상단 이미지
            Image.asset(
              'assets/building.png', // 텍스트 포함된 배너 이미지도 가능
              width: double.infinity,
              height: 220,
              fit: BoxFit.contain,
            ),

            SizedBox(height: 30),

            // ✅ 말풍선 1: 왼쪽 하단 뾰족 + 전화기 아이콘
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/call_image.png', width: 24), // 전화기 아이콘
                  SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                          bottomLeft: Radius.circular(0), // 뾰족하게 남김
                        ),
                      ),
                      child: Text(
                        '"학과 사무실에 전화를 걸어 장학금에 대해 문의하고 있습니다. 학과에서 제공하는 장학금 프로그램을 확인하고, 해당 전공과 학년에 맞는 장학금을 알아보려 합니다."',
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // ✅ 말풍선 2: 오른쪽 하단 뾰족 + 손가락 아이콘
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(0), // 뾰족하게 남김
                        ),
                      ),
                      child: Text(
                        '통화를 마치실 준비가 되셨다면,\n‘종료’ 버튼을 눌러주세요.',
                        style: TextStyle(fontSize: 13),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Image.asset('assets/touch_image.png', width: 24), // 손가락 아이콘
                ],
              ),
            ),

            Spacer(),

            // ✅ 하단 버튼 영역
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(Icons.dialpad, size: 32, color: Colors.grey.shade600),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(16),
                    ),
                    child: Icon(Icons.call_end, size: 28, color: Colors.white),
                  ),
                  Icon(Icons.volume_up, size: 32, color: Colors.grey.shade600),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
