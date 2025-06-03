import 'dart:convert';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'feedback_loading_page.dart';
import 'feedback_detail_page.dart';
import 'feedback_result_page.dart';

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

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  FlutterSoundPlayer player = FlutterSoundPlayer();
  FlutterSoundRecorder recorder = FlutterSoundRecorder();

  bool isRecording = false;
  late String audioPath;

  @override
  void initState() {
    super.initState();
    initRecorder();
    requestMicrophonePermission();
    player.openPlayer();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    player.closePlayer();
    super.dispose();
  }

  Future<void> requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    print("[Permission] 현재 마이크 권한 상태: $status");
    if (!status.isGranted) {
      var result = await Permission.microphone.request();
      print("[Permission] 마이크 권한 요청 결과: $result");
    }
  }

  Future<void> initRecorder() async {
    await recorder.openRecorder();
    print("[Recorder] Recorder 열림");
    await recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  Future<void> playRecording() async {
    if (audioPath.isNotEmpty) {
      final file = File(audioPath);
      if (await file.exists()) {
        await player.startPlayer(fromURI: audioPath);
        print("▶ 재생 시작: $audioPath");
      } else {
        print("⚠ 녹음된 파일이 존재하지 않습니다.");
      }
    } else {
      print("⚠ 녹음된 파일 경로가 없습니다.");
    }
  }

  Future<void> startRecording() async {
    var micStatus = await Permission.microphone.status;
    if (!micStatus.isGranted) {
      print("❗ 마이크 권한이 없습니다.");
      var req = await Permission.microphone.request();
      if (!req.isGranted) {
        print("❌ 마이크 권한 거부됨");
        return;
      }
    }

    Directory tempDir = await getTemporaryDirectory();
    audioPath = '${tempDir.path}/recorded_audio.aac';  // AAC 확장자 권장
    print("[녹음] 저장 경로: $audioPath");

    await recorder.startRecorder(
      toFile: audioPath,
      codec: Codec.aacADTS,
    );
    print("[녹음] 녹음 시작됨");
  }

  Future<void> stopRecording() async {
    await recorder.stopRecorder();
    print("[녹음] 녹음 종료됨");
    await getCacheFileSize(audioPath);
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
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(Icons.dialpad, size: 32, color: Colors.grey.shade600),
                  ElevatedButton(
                    onPressed: () async {
                      if (!isRecording) {
                        print("🔴 녹음 시작 버튼 클릭");
                        await startRecording();
                      } else {
                        print("⏹ 녹음 종료 버튼 클릭");
                        await stopRecording();
                        await sendToServer(File(audioPath));
                        //await evalAudio("tester1");
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
    try {
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', audioFile.path))
        ..fields['user_id'] = 'tester1';

      var response = await request.send();

      if (response.statusCode == 200) {
        print("✅ 파일 전송 성공");
        final responseBody = await response.stream.bytesToString();
        print("🎧 응답 데이터: $responseBody");
      } else {
        print("❌ 파일 전송 실패: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ 파일 전송 중 오류 발생: $e");
    }
  }

  // Future<void> evalAudio(String userId) async {
  //   var uri = Uri.parse("http://10.0.2.2:8000/evaluate-audio/?userId=$userId");
  //
  //   try {
  //     var response = await http.get(uri);
  //
  //     if (response.statusCode == 200) {
  //       var result = jsonDecode(response.body);
  //       print("✅ 평가 결과: $result");
  //     } else {
  //       print("❌ 서버 오류: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print("❌ 평가 요청 실패: $e");
  //   }
  // }
}
