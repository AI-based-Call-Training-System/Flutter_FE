import 'package:flutter/material.dart';

/// 카테고리 정의
enum HistoryCategory { all, school, work, order, greeting }

/// 히스토리 항목 모델
class HistoryItem {
  final String id;
  final String title;
  final String subtitle;
  final HistoryCategory category;

  const HistoryItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
  });
}

/// 카테고리 → 아이콘 에셋 매핑
/// 실제 파일 경로/파일명에 맞게 수정 가능
const Map<HistoryCategory, String> kCategoryAsset = {
  HistoryCategory.school:   'assets/school.png',
  HistoryCategory.work:     'assets/office.png',
  HistoryCategory.greeting: 'assets/plane.png',
  HistoryCategory.order:    'assets/cart.png', 
  // all은 개별 항목 category에 따라 표시되므로 별도 없음
};

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  static const pageBg = Color(0xFFF4F4F6);
  static const green  = Color(0xFF169976);
  static const gray50 = Color(0xFF656873);

  HistoryCategory _selected = HistoryCategory.all;

  // 데모 데이터
  final List<HistoryItem> _allItems = const [
    HistoryItem(
      id: 'sch-001',
      title: '학교1',
      subtitle: '학교 관련 문의 사항 전화',
      category: HistoryCategory.school,
    ),
    HistoryItem(
      id: 'ord-101',
      title: '주문1',
      subtitle: '배달 주문 관련 문의 사항 전화',
      category: HistoryCategory.order,
    ),
    HistoryItem(
      id: 'greet-01',
      title: '안부인사1',
      subtitle: '안부 인사 관련 전화',
      category: HistoryCategory.greeting,
    ),
    HistoryItem(
      id: 'greet-02',
      title: '안부인사2',
      subtitle: '안부 인사 관련 전화',
      category: HistoryCategory.greeting,
    ),
    HistoryItem(
      id: 'work-01',
      title: '직장1',
      subtitle: '인사팀 문의 전화',
      category: HistoryCategory.work,
    ),
  ];

  List<HistoryItem> get _items {
    if (_selected == HistoryCategory.all) return _allItems;
    return _allItems.where((e) => e.category == _selected).toList();
  }

  /// 카테고리 라벨
  String _label(HistoryCategory cat) {
    switch (cat) {
      case HistoryCategory.all:      return '전체';
      case HistoryCategory.school:   return '학교';
      case HistoryCategory.work:     return '직장';
      case HistoryCategory.order:    return '주문';
      case HistoryCategory.greeting: return '안부인사';
    }
  }

  /// 섹션 타이틀 (선택된 필터에 따라 변경)
  String _sectionTitle(HistoryCategory c) => '${_label(c)} 히스토리';

  /// 상단 카테고리 필터 (5등분 1줄, 텍스트 완전 중앙)
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
              alignment: Alignment.center, // 세로/가로 완전 중앙
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
                  height: 1.0, // 폰트 기준선 보정
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
        children: [
          chip(HistoryCategory.all),
          chip(HistoryCategory.school),
          chip(HistoryCategory.work),
          chip(HistoryCategory.order),
          chip(HistoryCategory.greeting),
        ],
      ),
    );
  }

  /// 리스트 아이템 카드
  Widget _buildListCard(HistoryItem item) {
    final String? asset = kCategoryAsset[item.category];

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/feedbackResult',
          arguments: item,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // 왼쪽 썸네일 (카테고리별 아이콘)
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

            // 제목/부제
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
                      fontFamily: 'Noto Sans',
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                      letterSpacing: -0.32,
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
                      fontFamily: 'Noto Sans',
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                      letterSpacing: -0.28,
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
        title: const Text(
          '히스토리',
        ),
        titleTextStyle: const TextStyle(
          color: Color(0xFF111214),
          fontSize: 16,
          fontFamily: 'Noto Sans',
          fontWeight: FontWeight.w600,
          height: 1.5,
          letterSpacing: -0.32,
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: pageBg, // 헤더도 배경색과 동일
        foregroundColor: const Color(0xFF111214),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카테고리 필터 (5등분 1줄)
          _buildCategoryRow(),

          // 섹션 타이틀 (선택된 필터명으로 변경)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
            child: Text(
              _sectionTitle(_selected),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'Noto Sans',
                fontWeight: FontWeight.w600,
                height: 1.50,
                letterSpacing: -0.36,
              ),
            ),
          ),

          // 리스트
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildListCard(_items[index]),
            ),
          ),
        ],
      ),
    );
  }
}
