import 'dart:convert';
import 'dart:io' as io;
import 'dart:async';
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

const lightColor = Color(0xFF80D9CD);
const grayColor = Color(0xFFF6F7FA);
const pointColor = Color(0xFFFFE4D4); // 활성(녹음 후) 살구
const pointDisabledColor = Color(0xFFFFF0E6); // 비활성(녹음 전) 연한 살구

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
  final List<html.Blob> _audioChunks = [];
  html.Blob? _audioBlob;
  bool _isWebRecording = false;

  // 녹음 완료 여부
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
        // ignore: avoid_print
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
      isRecorded = false;
    });
  }

  // 모바일 녹음 중지
  Future<void> stopMobileRecording() async {
    await recorder!.stopRecorder();
    setState(() {
      _statusText = "녹음 완료! 재생 가능";
      isRecording = false;
      isRecorded = true;
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
      final stream =
          await html.window.navigator.mediaDevices!.getUserMedia({'audio': true});
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
          isRecorded = true;
        });
      });

      _mediaRecorder!.start();
      setState(() {
        _statusText = "녹음 중...";
        _isWebRecording = true;
        isRecorded = false;
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

    Timer(const Duration(minutes: 1), () {
      audio.remove();
      html.Url.revokeObjectUrl(url);
    });

    setState(() {
      _statusText = "재생 중...";
    });
  }

  // 녹음 시작/종료 토글
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

  // 녹음 재생
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

      // 상단 AppBar: 그림자/틴트 제거
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        titleSpacing: 16,
        title: const Text(
          '통화훈련',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
      ),

      // 하단 녹음 바: 그림자 제거 + 얇은 상단 보더
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            // border: Border(
            //   top: BorderSide(color: Color(0x14000000), width: 1), // 미세한 구분선
            // ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // AI 음성 듣기
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('AI 음성 재생 준비중입니다.')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: lightColor, width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  icon: const Icon(Icons.graphic_eq),
                  label: const Text('AI 음성 듣기'),
                ),
              ),

              const SizedBox(width: 12),

              // 가운데: 녹음 시작/중지 (원형)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: toggleRecording,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          (isRecording || _isWebRecording) ? Colors.red : lightColor,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(18),
                      elevation: 0,
                      foregroundColor: Colors.white,
                    ),
                    child: Icon(
                      (isRecording || _isWebRecording) ? Icons.stop : Icons.mic,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    (isRecording || _isWebRecording) ? '녹음 중지' : '녹음 시작',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),

              const SizedBox(width: 12),

              // 통화 녹음 듣기 (재생)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: playRecording,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lightColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('통화 녹음 듣기'),
                ),
              ),
            ],
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Image.asset(
              'assets/building.png',
              width: double.infinity,
              height: 220,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),

            // --- 첫 말풍선 (왼쪽) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/call_image.png', width: 24),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: _Balloon(
                      text:
                          '"학과 사무실에 전화를 걸어 장학금에 대해 문의하고 있습니다..."',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // --- 두 번째 말풍선 (왼쪽 연속) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(width: 32),
                  Flexible(
                    child: _Balloon(
                      text:
                          '통화를 마치실 준비가 되셨다면,\n‘종료’ 버튼을 눌러주세요.',
                      small: true,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 👇 컨텐츠를 위로 밀어 "피드백 확인"을 아래로
            const Spacer(),

            // ✅ 피드백 확인 버튼 (하단 고정 느낌)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isRecorded
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FeedbackResultPage(),
                            ),
                          );
                        }
                      : null,
                  style: ButtonStyle(
                    elevation: const MaterialStatePropertyAll(0),
                    padding: const MaterialStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 16),
                    ),
                    shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    backgroundColor:
                        MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.disabled)) {
                        return pointDisabledColor; // 연한 살구
                      }
                      return pointColor; // 활성 살구
                    }),
                    foregroundColor:
                        MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.disabled)) {
                        return const Color(0xFFB9B9B9);
                      }
                      return const Color(0xFF3A3A3A);
                    }),
                  ),
                  child: const Text(
                    "피드백 확인",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// 말풍선 위젯 분리 (가독성)
class _Balloon extends StatelessWidget {
  final String text;
  final bool small;
  const _Balloon({required this.text, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(small ? 12 : 14),
      decoration: BoxDecoration(
        color: grayColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(small ? 8 : 12),
          topRight: const Radius.circular(12),
          bottomRight: const Radius.circular(12),
          bottomLeft: const Radius.circular(0),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: small ? 13 : 14, color: Colors.black),
      ),
    );
  }
}
