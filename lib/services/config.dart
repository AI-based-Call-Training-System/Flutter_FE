import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

// 서버 주소 설정
const String _BASE_URL_WEB = 'http://localhost:3000'; // ← 여기 LAN IP로 변경
const String _BASE_URL_ANDROID = 'http://10.0.2.2:3000';
const String _BASE_URL_IOS = 'http://localhost:3000';

String get BASE_URL {
  if (kIsWeb) {
    // print("web으로 열림");
    return _BASE_URL_WEB;
  } else if (Platform.isAndroid) {
    return _BASE_URL_ANDROID;
  } else if (Platform.isIOS) {
    return _BASE_URL_IOS;
  } else {
    return _BASE_URL_WEB;
  }
}
