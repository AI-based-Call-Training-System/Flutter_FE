import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// 웹 전용
import 'dart:html' as html;

// 모바일 전용
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

import 'feedback_result_page.dart';

class CallPage extends StatefulWidget {
  final String scenario;
  const CallPage({required this.scenario, super.key});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  // --- 모바일용 녹음 플레이어 & 레코더 ---
  FlutterSoundPlayer? player;
  FlutterSoundRecorder? recorder;
  String? audioPath;
  bool isRecording = false;

  // --- 웹용 녹음 변수 ---
  html.MediaRecorder? _mediaRecorder;
  List<html.Blob> _audioChunks = [];
  html.Blob? _audioBlob;
  bool _isWebRecording = false;

  // 녹음 완료 여부 플래그
  bool isRecorded = false;

  String _statusText = "녹음 준비 완료";

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // 웹 초기화 없음
    } else {
      player = FlutterSoundPlayer();
      recorder = FlutterSoundRecorder();
      initRecorder();
      requestMicrophonePermission();
      player!.openPlayer();
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      _mediaRecorder?.stop();
    } else {
      recorder?.closeRecorder();
      player?.closePlayer();
    }
    super.dispose();
  }

  // 모바일 권한 요청
  Future<void> requestMicrophonePermission() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        await Permission.microphone.request();
      }
    }
  }

  // 모바일 녹음 초기화
  Future<void> initRecorder() async {
    if (!kIsWeb && recorder != null) {
      await recorder!.openRecorder();
      await recorder!.setSubscriptionDuration(const Duration(milliseconds: 500));
      final status = await recorder!.isEncoderSupported(Codec.aacADTS);
      if (!status) {
        print('AAC 인코딩 미지원');
      }
    }
  }

  // 모바일 녹음 시작
  Future<void> startMobileRecording() async {
    final tempDir = await getTemporaryDirectory();
    audioPath = '${tempDir.path}/recorded_audio.aac'; // 모바일은 aac 사용
    await recorder!.startRecorder(
      toFile: audioPath,
      codec: Codec.aacADTS,
    );
    setState(() {
      _statusText = "녹음 중...";
      isRecording = true;
      isRecorded = false; // 녹음 다시 시작하면 false로
    });
  }

  // 모바일 녹음 중지
  Future<void> stopMobileRecording() async {
    await recorder!.stopRecorder();
    setState(() {
      _statusText = "녹음 완료! 재생 가능";
      isRecording = false;
      isRecorded = true; // 녹음 완료 표시
    });
  }

  // 모바일 녹음 재생
  Future<void> playMobileRecording() async {
    if (audioPath == null) {
      setState(() {
        _statusText = "녹음된 파일이 없습니다.";
      });
      return;
    }
    await player!.startPlayer(fromURI: audioPath);
    setState(() {
      _statusText = "재생 중...";
    });
  }

  // --- 웹용 녹음 시작 ---
  Future<void> startWebRecording() async {
    try {
      final stream = await html.window.navigator.mediaDevices!.getUserMedia({'audio': true});
      _audioChunks.clear();
      _mediaRecorder = html.MediaRecorder(stream);

      _mediaRecorder!.addEventListener('dataavailable', (event) {
        final blobEvent = event as html.BlobEvent;
        if (blobEvent.data != null) {
          _audioChunks.add(blobEvent.data!);
        }
      });

      _mediaRecorder!.addEventListener('stop', (event) {
        _audioBlob = html.Blob(_audioChunks, 'audio/webm');
        setState(() {
          _statusText = "녹음 완료! 재생 가능";
          _isWebRecording = false;
          isRecorded = true; // 녹음 완료 표시
        });
      });

      _mediaRecorder!.start();
      setState(() {
        _statusText = "녹음 중...";
        _isWebRecording = true;
        isRecorded = false; // 녹음 다시 시작하면 false로
      });
    } catch (e) {
      setState(() {
        _statusText = "녹음 시작 실패: $e";
      });
    }
  }

  // --- 웹용 녹음 중지 ---
  Future<void> stopWebRecording() async {
    _mediaRecorder?.stop();
  }

  // --- 웹용 녹음 재생 ---
  Future<void> playWebRecording() async {
    if (_audioBlob == null) {
      setState(() {
        _statusText = "녹음된 음성이 없습니다.";
      });
      return;
    }
    final url = html.Url.createObjectUrlFromBlob(_audioBlob!);
    final audio = html.AudioElement()
      ..src = url
      ..controls = true
      ..autoplay = true;
    html.document.body!.append(audio);

    Timer(Duration(minutes: 1), () {
      audio.remove();
      html.Url.revokeObjectUrl(url);
    });

    setState(() {
      _statusText = "재생 중...";
    });
  }

  // 녹음 시작/종료 토글 함수
  Future<void> toggleRecording() async {
    if (kIsWeb) {
      if (_isWebRecording) {
        await stopWebRecording();
      } else {
        await startWebRecording();
      }
    } else {
      if (isRecording) {
        await stopMobileRecording();
      } else {
        await startMobileRecording();
      }
    }
  }

  // 녹음 재생 함수
  Future<void> playRecording() async {
    if (kIsWeb) {
      await playWebRecording();
    } else {
      await playMobileRecording();
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
              onPressed: playRecording,
              icon: Icon(Icons.play_arrow),
              label: Text("녹음 재생"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),

            SizedBox(height: 16),

            // 녹음 완료시만 보이는 피드백 확인 버튼
            if (isRecorded)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FeedbackResultPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: Size(double.infinity, 50),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text("피드백 확인"),
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
                      await toggleRecording();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRecording || _isWebRecording ? Colors.red : Colors.green,
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
