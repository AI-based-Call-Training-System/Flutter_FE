import 'package:call_20250331/services/restapi_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'feedback_result_page.dart';
import './pref/pref_manger.dart';

enum HistoryCategory { all, school, work, order, greeting }

class HistoryItem {
  final String? id;
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

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
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
  static const pageBg = Color(0xFFF4F6F8);
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

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded is List) {
          setState(() {
            _items = decoded
                .map((e) => HistoryItem.fromJson(
                    Map<String, dynamic>.from(e)))
                .toList();
            _items = _applyTitleNumbering(_items);
            _loading = false;
          });
        } else if (decoded is Map && decoded.containsKey('items')) {
          final data = decoded['items'] as List<dynamic>;
          setState(() {
            _items = data
                .map((e) => HistoryItem.fromJson(
                    Map<String, dynamic>.from(e)))
                .toList();
            _items = _applyTitleNumbering(_items);
            _loading = false;
          });
        } else {
          setState(() => _loading = false);
        }
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  List<HistoryItem> _applyTitleNumbering(List<HistoryItem> items) {
    final Map<String, int> titleCount = {};
    for (final item in items) {
      titleCount[item.title] = (titleCount[item.title] ?? 0) + 1;
    }
    final Map<String, int> currentNum = Map.from(titleCount);
    final List<HistoryItem> numbered = [];
    for (final item in items) {
      final title = item.title;
      final count = currentNum[title]!;
      currentNum[title] = count - 1;
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
                border: selected ? Border.all(color: green, width: 1.5) : null,
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
        children:
            HistoryCategory.values.map((cat) => chip(cat)).toList(growable: false),
      ),
    );
  }

  // ✅ TrainingPage와 동일 포맷의 카드
  Widget _buildListCard(HistoryItem item) {
    final String? asset = kCategoryAsset[item.category];

    void go() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FeedbackResultPage(initialSessionId: item.sessionId,needEval: false),
        ),
      );
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: go,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 110, // TrainingPage 카드와 동일
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              // 아이콘
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  //color: const Color(0xFFE9EDF1),
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
              const SizedBox(width: 16),

              // 텍스트
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더 (TrainingPage와 동일한 여백/폰트)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 28, 16, 12),
                    child: Row(
                      children: [
                        Text(
                          '히스토리',
                          style: t.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),

                  // 카테고리 칩
                  _buildCategoryRow(),

                  // 섹션 타이틀
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Text(
                      _sectionTitle(_selected),
                      style: t.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 리스트
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: _filteredItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 20),
                      itemBuilder: (context, index) =>
                          _buildListCard(_filteredItems[index]),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
