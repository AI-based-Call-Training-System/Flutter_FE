import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<void> getCacheFileSize(String fileName) async {
  try {
    final cacheDir = await getTemporaryDirectory();
    final filePath = '${cacheDir.path}/$fileName';
    final file = File(filePath);

    if (await file.exists()) {
      final length = await file.length();
      print('파일 크기: $length bytes');
    } else {
      print('파일이 존재하지 않습니다.');
    }
  } catch (e) {
    print('오류 발생: $e');
  }
}

void main() async {
  await getCacheFileSize('recorded_audio.wav');
}