import 'dart:convert';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart'; // Codec 포함된 패키지
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'feedback_loading_page.dart';
import 'feedback_detail_page.dart';
import 'feedback_result_page.dart';
// import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// 함수 정의
Future<void> getCacheFileSize(String filePath) async {
  final file = File(filePath);

  if (await file.exists()) {
    final length = await file.length();
    print('파일 크기: $length bytes');
  } else {
    print('파일이 존재하지 않습니다.');
  }
}


class CallPage extends StatefulWidget {
  final String scenario;
  const CallPage({required this.scenario, super.key});

  //CallPage({required this.scenario});
  @override
  State<CallPage> createState() => _CallPageState();
}
class _CallPageState extends State<CallPage> {
  FlutterSoundPlayer player = FlutterSoundPlayer();
  @override
  void initState() {
    super.initState();
    initRecorder();
    requestMicrophonePermission();
    player.openPlayer(); // 🎧 플레이어 열기
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    player.closePlayer(); // 🎧 플레이어 닫기
    super.dispose();
  }

  // 🔽 녹음 상태 변수 및 경로 정의 (나중에 녹음 시작/종료 구현 시 필요)
  bool isRecording = false;
  FlutterSoundRecorder recorder = FlutterSoundRecorder();
  late String audioPath;


  Future<void> requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  Future<void> playRecording() async {
    if (audioPath.isNotEmpty) {
      await player.startPlayer(fromURI: audioPath);
      print("▶ 재생 시작: $audioPath");
    } else {
      print("⚠ 녹음된 파일이 없습니다.");
    }
  }


  Future<void> initRecorder() async {
    await recorder.openRecorder();
    await recorder.setSubscriptionDuration(const Duration(milliseconds: 500));

    final status = await recorder.isEncoderSupported(Codec.aacADTS);
    if (!status) {
      print('AAC 인코딩 미지원');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Image.asset(
              'assets/building.png',
              width: double.infinity,
              height: 220,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 30),

            // 첫 말풍선
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/call_image.png', width: 24),
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
                          bottomLeft: Radius.circular(0),
                        ),
                      ),
                      child: Text(
                        '"학과 사무실에 전화를 걸어 장학금에 대해 문의하고 있습니다..."',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // 두 번째 말풍선
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          bottomRight: Radius.circular(0),
                        ),
                      ),
                      child: Text(
                        '통화를 마치실 준비가 되셨다면,\n‘종료’ 버튼을 눌러주세요.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Image.asset('assets/touch_image.png', width: 24),
                ],
              ),
            ),

            Spacer(),

            ElevatedButton.icon(
              onPressed: () async {
                await playRecording();
              },
              icon: Icon(Icons.play_arrow),
              label: Text("녹음 재생"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),


            // 하단 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(Icons.dialpad, size: 32, color: Colors.grey.shade600),
                  ElevatedButton(
                    onPressed: () async {
                      if (!isRecording) {
                        // 녹음 시작
                        Directory tempDir = await getTemporaryDirectory();
                        audioPath = '${tempDir.path}/recorded_audio.wav';
                        await recorder.startRecorder(
                            toFile: audioPath,
                            codec: Codec.pcm16WAV, // ✅ 변경: WAV로 저장
                            );
                        print("✅ 녹음 시작됨: $audioPath");
                      } else {
                        // 녹음 종료 + 서버 전송
                        await recorder.stopRecorder();
                        print("🛑 녹음 종료됨");
                        print("📁 파일 경로: $audioPath");
                        getCacheFileSize(audioPath);

                        await sendToServer(File(audioPath));
                        await evalAudio("tester1");

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FeedbackResultPage()),
                        );
                      }
                      setState(() {
                        isRecording = !isRecording;
                      });
                    },
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

  Future<void> sendToServer(File audioFile) async {
    var uri = Uri.parse('http://10.0.2.2:8000/chat/audio');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', audioFile.path))
      ..fields['user_id'] = 'tester1';  // ✅ 여기에 사용자 ID 넣기

    var response = await request.send();

    if (response.statusCode == 200) {
      print("✅ 파일 전송 성공");
      final responseBody = await response.stream.bytesToString();
      print("🎧 응답 데이터: $responseBody");
    } else {
      print("❌ 파일 전송 실패: ${response.statusCode}");
    }
  }

  Future<void> evalAudio(String userId) async {
    var uri = Uri.parse("http://10.0.2.2:8000/evaluate-audio/?userId=$userId");

    try {
      var response = await http.get(uri); // 파일 없음 → GET 요청 가능

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print("✅ 평가 결과: $result");

        // 결과 전달 or 화면 이동
      } else {
        print("❌ 서버 오류: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ 요청 실패: $e");
    }
  }
}


