import 'package:call_20250331/services/restapi_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'feedback_result_page.dart';
import './pref/pref_manger.dart';
/// 카테고리 정의
enum HistoryCategory { all, school, work, order, greeting }

/// 세션 히스토리 항목 모델
class HistoryItem {
  final String? id; // null 허용
  final String userId;
  final String sessionId;
  final String title;
  final String subtitle;
  final HistoryCategory category;

  HistoryItem({
    this.id,
    required this.userId,
    required this.sessionId,
    required this.title,
    required this.subtitle,
    required this.category,
  });

  /// JSON → 모델 변환
  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    // tag 기반 카테고리 매핑
    HistoryCategory cat = HistoryCategory.all;
    if (json['tags'] != null && json['tags'].isNotEmpty) {
      final tag = json['tags'] as String;
      switch (tag) {
        case 'school':
          cat = HistoryCategory.school;
          break;
        case 'work':
          cat = HistoryCategory.work;
          break;
        case 'order':
          cat = HistoryCategory.order;
          break;
        case 'greeting':
          cat = HistoryCategory.greeting;
          break;
        default:
          cat = HistoryCategory.all;
      }
    }

    return HistoryItem(
      id: json['_id'] != null ? json['_id']['\$oid'] : null,
      userId: json['userId'] ?? '',
      sessionId: json['sessionId'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['history'] != null && (json['history'] as List).isNotEmpty
          ? (json['history'] as List).last['content'] ?? ''
          : '',
      category: cat,
    );
  }
}

/// 카테고리 → 아이콘 매핑
const Map<HistoryCategory, String> kCategoryAsset = {
  
  HistoryCategory.school: 'assets/school.png',
  HistoryCategory.work: 'assets/office.png',
  HistoryCategory.greeting: 'assets/plane.png',
  HistoryCategory.order: 'assets/cart.png',
};

class HistoryPage extends StatefulWidget {
  // final String userId;
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  static const pageBg = Color(0xFFF4F4F6);
  static const green = Color(0xFF169976);
  static const gray50 = Color(0xFF656873);

  HistoryCategory _selected = HistoryCategory.all;

  List<HistoryItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchSessions();
  }

  /// NestJS API 호출
  Future<void> _fetchSessions() async {
    String? userId=await PrefManager.getUserId();
    final uri = Uri.parse(
        'http://localhost:3000/history/${userId}/sessions');
    print(uri);
    final token = await PrefManager.getJWTtoken();
try {
  final res = await http.get(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  print("statusCode: ${res.statusCode}");
  print("body type: ${res.body.runtimeType}");
  print("body raw: ${res.body}");

  if (res.statusCode == 200) {
    final decoded = json.decode(res.body);

    // 🧩 1. decoded가 리스트인지 맵인지 확인
    if (decoded is List) {
      // 서버가 리스트만 반환한 경우
      setState(() {
        _items = decoded.map((e) => HistoryItem.fromJson(Map<String, dynamic>.from(e))).toList();
        _items = _applyTitleNumbering(_items);
        _loading = false;
      });
    } else if (decoded is Map && decoded.containsKey('items')) {
      // 서버가 { ok, items: [...] } 형태로 반환한 경우
      final data = decoded['items'] as List<dynamic>;
      setState(() {
        _items = data.map((e) => HistoryItem.fromJson(Map<String, dynamic>.from(e))).toList();
        _items = _applyTitleNumbering(_items);
        _loading = false;
      });
    } else {
      print("⚠️ 예상치 못한 응답 구조: $decoded");
      setState(() => _loading = false);
    }
  } else {
    setState(() => _loading = false);
    print('❌ Error: status code ${res.statusCode}');
  }
} catch (e) {
  setState(() => _loading = false);
  print("여기에러: $e");
}
  }

List<HistoryItem> _applyTitleNumbering(List<HistoryItem> items) {
  // 1. 제목별 총 등장 횟수 계산
  final Map<String, int> titleCount = {};
  for (final item in items) {
    titleCount[item.title] = (titleCount[item.title] ?? 0) + 1;
  }

  // 2. 현재 붙일 번호를 관리 (총 개수부터 시작)
  final Map<String, int> currentNum = Map.from(titleCount);

  final List<HistoryItem> numbered = [];

  // 3. 아이템 순회하며 역순 번호 붙이기
  for (final item in items) {
    final title = item.title;
    final count = currentNum[title]!; // 현재 번호
    currentNum[title] = count - 1;   // 다음 아이템은 1 감소

    final newTitle = '$title$count';

    numbered.add(HistoryItem(
      id: item.id,
      userId: item.userId,
      sessionId: item.sessionId,
      title: newTitle,
      subtitle: item.subtitle,
      category: item.category,
    ));
  }

  return numbered;
}
  List<HistoryItem> get _filteredItems {
    if (_selected == HistoryCategory.all) return _items;
    return _items.where((e) => e.category == _selected).toList();
  }

  String _label(HistoryCategory cat) {
    switch (cat) {
      case HistoryCategory.all:
        return '전체';
      case HistoryCategory.school:
        return '학교';
      case HistoryCategory.work:
        return '직장';
      case HistoryCategory.order:
        return '주문';
      case HistoryCategory.greeting:
        return '안부인사';
    }
  }

  String _sectionTitle(HistoryCategory c) => '${_label(c)} 히스토리';

  Widget _buildCategoryRow() {
    Widget chip(HistoryCategory cat) {
      final selected = _selected == cat;
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () => setState(() => _selected = cat),
            child: Container(
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border:
                    selected ? Border.all(color: green, width: 1.5) : null,
              ),
              child: Text(
                _label(cat),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.0,
                  letterSpacing: -0.2,
                  color: selected ? green : gray50,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: HistoryCategory.values
            .map((cat) => chip(cat))
            .toList(growable: false),
      ),
    );
  }

  Widget _buildListCard(HistoryItem item) {
    final String? asset = kCategoryAsset[item.category];
    return InkWell(
     onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FeedbackResultPage(
              initialSessionId: item.sessionId,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFE9EDF1),
              ),
              clipBehavior: Clip.antiAlias,
              child: asset == null
                  ? const SizedBox()
                  : Image.asset(
                      asset,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF111214),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF656873),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        title: const Text('히스토리'),
        backgroundColor: pageBg,
        foregroundColor: const Color(0xFF111214),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategoryRow(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                  child: Text(
                    _sectionTitle(_selected),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: _filteredItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _buildListCard(_filteredItems[index]),
                  ),
                ),
              ],
            ),
    );
  }
}
