import 'dart:convert';

import 'dart:io' as io;
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'dart:async';

//api 서비스 호출용
import '../services/restapi_service.dart'; // API 클래스 호출용

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

  // --- 세션 관리용 변수 ---
  String? sessionId;

  // --- 아이디 관리용 변수 ---
  String? userId;
  String? token;

  String? currentScenario;

  String getScenarioImage() {
  switch (widget.scenario) {
    case 'order':
      return 'assets/call_cart.png';
    case 'greeting':
      return 'assets/call_greeting.png';
    case 'school':
      return 'assets/call_school.png';
    case 'work':
      return 'assets/call_work.png';
    default:
      return 'assets/call_default.png'; // fallback 이미지
  }
}

  @override
  void initState() {
    super.initState();
    currentScenario=widget.scenario;
    _getUseridAndSessionAndtoken();


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

//세션 생성 함수

  Future<void> _getUseridAndSessionAndtoken() async {
    userId= await PrefManager.getUserId(); // nullable 내포
    sessionId = await SessionApiService().getSession(userId,currentScenario);
    token= await PrefManager.getJWTtoken();
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
      ..controls = false
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
    _currentAudio = audio;

    // 재생이 끝나면 오디오 제거
    audio.onEnded.listen((event) {
      audio.remove();
      html.Url.revokeObjectUrl(url);
      if (_currentAudio == audio) _currentAudio = null;
    });
  }

  // 사용자 음성 백엔드 전송 함수
  Future<void> sendAudioToFastAPIWeb() async 
  {
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

      /*
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:8000/chat/audio'),
      );

      //나중에 리팩토링 해야될거같음
      //여기서 api를 정의할게 아니라 restapi_service.dart를 정의하는게 맞을듯

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
      */
      
      Map<String, dynamic> data = {}; // 빈 Map으로 초기화

      if (userId !=null|| token !=null) {
        print("api 호출");
        data = await CallApiService().sendUserAudio(userId!,token!,bytes,sessionId!,currentScenario!);
      }
      else{
        print("오디오 또는 userId가 지정되지 않음");

      }
    
      if(data['user_input']!=null){
        print("User Input: ${data['user_input']}");
        print("Gemini Reply: ${data['gemini_reply']}");
        print("TTS Audio Path: ${data['tts_audio_path']}");

      }
      else{print("userinput이 null$data");}

      if (kIsWeb) {// 앱이 웹에서 구동중이라면
      Uint8List bytes = base64Decode(data['tts_audio_base64']??"");
      playTTSWebFromBytes(bytes); // 이전에 만든 Blob URL 재생 함수
      print("blob 재생");
      } else {
        print("앱에서의 tts play는 아직 구현되지 않았습니다.");
      }
      }
      catch (e) {
      print("sendauido예외발생: $e");
    }
  }

//웹브라우저에서 음성파일을 받아 어떻게 재생할지

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
                  onPressed: ()async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('AI 음성 재생 준비중입니다.')),
                    );
                    await sendAudioToFastAPIWeb();
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

      // body: SafeArea(
      //   child: Stack(
      //     alignment: Alignment.topCenter,
      //     children: [
      //       // 원형 그라데이션 배경
      //       Container(
      //         width: double.infinity,
      //         height: 220, // 이미지와 동일한 높이
      //         decoration: BoxDecoration(
      //           shape: BoxShape.circle,
      //           gradient: RadialGradient(
      //             colors: [
      //               Color(0xFF06B69E), // 중심 색상
      //               Color(0xFF06B69E).withOpacity(0.0), // 바깥쪽으로 투명하게
      //             ],
      //             radius: 0.8, // 원이 퍼지는 정도
      //             center: Alignment.topCenter, // 이미지 중심에 맞춤
      //           ),
      //         ),
      //       ),
      body: SafeArea(
              child: Column(
                children: [
            Image.asset(
              getScenarioImage(),
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
                          '"치킨집에 전화를 걸어 치킨 종류 1마리와 콜라를 전자정보 3관으로 시키고 있습니다..."',
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
                  onPressed: (isRecorded && sessionId != null)
                      ? () {
                                // 현재 재생 중인 오디오 제거
                          _currentAudio?.remove();
                          _currentAudio = null;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => 
                              FeedbackResultPage(
                                initialSessionId:sessionId!,
                                needEval:true,
                                ),
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
