import 'dart:convert';

import 'dart:io' as io;
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';

import 'dart:async';


// 웹 전용
import 'dart:html' as html;

// 모바일 전용
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;


import 'feedback_result_page.dart';
import 'dart:typed_data';

//userid 참조 매니져
import '../pref/pref_manger.dart';



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


  // GEMINI 오디오 객체 관리
  static html.AudioElement? _currentAudio;

  //gemini tts 재생 함수 
  static void playTTSWebFromBytes(Uint8List bytes) {
    //GEMINI의 오디오 객체는 하나여야 하니,
    //STATIC으로 관리
    //중복 호출시 기존 객체 중지 및 종료
    _currentAudio?.pause();
    _currentAudio?.remove();

    // 새 오디오 생성
    // 바이트를 Blob으로 감싸기
    final blob = html.Blob([bytes], 'audio/wav'); // wav 파일이면 audio/wav
    //Blob을 임시 URL로 변환 (예:blob:http://localhost:1234/abcd...)
    final url = html.Url.createObjectUrlFromBlob(blob);

    // AudioElement 생성
    final audio = html.AudioElement()
      ..src = url
      ..autoplay = true
      // 오디오 ui 객체는 필요없으므로 false
      ..controls = false;

    html.document.body!.append(audio);

    // 재생이 끝나면 오디오 제거
    audio.onEnded.listen((event) {
      audio.remove();
      html.Url.revokeObjectUrl(url);
    });
  }

  // 사용자 음성 백엔드 전송 함수
  Future<void> sendAudioToFastAPIWeb() async {
    if (_audioBlob == null) {
      print("녹음 파일이 없습니다.");
      return;
    }
    
    try {
      final reader = html.FileReader();
      reader.readAsArrayBuffer(_audioBlob!);
      await reader.onLoad.first;

      // Uint8List로 직접 변환 (웹에서 안전)
      final bytes = reader.result as Uint8List;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:8000/chat/audio'),
      );

      //나중에 리팩토링 해야될거같음
      //여기서 api를 정의할게 아니라 restapi_service.dart를 정의하는게 맞을듯

      //api form 필드에 user_id 테스트 고정값-> 요청 사용자 id 로 전환
      String? userId = await PrefManager.getUserId(); // nullable 내포
      //아래줄 널값처리 안하면 에러남
      request.fields['user_id'] = userId ?? 'noID'; // null이면 빈 문자열

    
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'recorded_audio.webm',
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("User Input: ${data['user_input']}");
        print("Gemini Reply: ${data['gemini_reply']}");
        print("TTS Audio Path: ${data['tts_audio_path']}");

        if (kIsWeb) {// 앱이 웹에서 구동중이라면
          Uint8List bytes = base64Decode(data['tts_audio_base64']);
          playTTSWebFromBytes(bytes); // 이전에 만든 Blob URL 재생 함수
        } else {
          print("앱에서의 tts play는 아직 구현되지 않았습니다.");
        }

      } else {
        print("FastAPI 전송 실패: ${response.statusCode} / ${response.body}");
      }
    } catch (e) {
      print("Exception 발생: $e");
    }
  }

//웹브라우저에서 음성파일을 받아 어떻게 재생할지

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
              onPressed: playRecording,
              icon: Icon(Icons.play_arrow),
              label: Text("녹음 재생"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),

            SizedBox(height: 16),

            // 녹음 완료시만 보이는 피드백 확인 버튼
            if (isRecorded)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    // Gemini 답변받기 버튼
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (kIsWeb && _audioBlob != null) {
                            await sendAudioToFastAPIWeb();
                          } else {
                            print("녹음 파일이 없습니다.");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: Size(double.infinity, 50),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: Text("Gemini 답변받기"),
                      ),
                    ),

                    SizedBox(width: 16),

                    // 기존 피드백 확인 버튼
                    Expanded(
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
                  ],
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