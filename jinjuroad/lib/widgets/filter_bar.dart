import 'package:flutter/material.dart';
import '../types.dart';
import '../theme/colors.dart';

class FilterBar extends StatelessWidget {
  final List<Event> events;
  final String filter; // 현재 선택된 필터 (예: "all", "festival")
  final Function(String) setFilter;
  final Language language;
  // getUIText는 간단한 맵으로 대체합니다.
  // 실제 앱에서는 getUIText('filterByCategory')를 호출해야 합니다.
  final String title; // 예: "카테고리별 필터"

  const FilterBar({
    Key? key,
    required this.events,
    required this.filter,
    required this.setFilter,
    required this.language,
    required this.title,
  }) : super(key: key);

  // TSX의 카테고리 추출 로직
  List<LocalizedString> _getCategories() {
    final categories = <LocalizedString>[
      LocalizedString(ko: '전체', en: 'All'), // 'All' 카테고리
    ];

    // Set을 사용해 유니크한 카테고리(en)를 저장
    final uniqueCategoryEn = <String>{};
    for (var event in events) {
      if (uniqueCategoryEn.add(event.category.en)) {
        // 유니크한 경우에만 LocalizedString 객체 추가
        categories.add(event.category);
      }
    }
    return categories;
  }

  @override
  Widget build(BuildContext context) {
    final categories = _getCategories();

    // TSX: <div className="bg-brand-secondary p-4 rounded-lg ...">
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0), // p-4
      decoration: BoxDecoration(
        color: AppColors.brandSecondary, // bg-brand-secondary (흰색)
        borderRadius: BorderRadius.circular(8.0), // rounded-lg
        border: Border.all(color: AppColors.gray200, width: 1.0), // border
        boxShadow: [ // shadow-sm
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TSX: <h3 className="text-lg font-semibold ...">
          Text(
            title, // getUIText('filterByCategory')
            style: const TextStyle(
              fontSize: 18.0, // text-lg
              fontWeight: FontWeight.w600, // font-semibold
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12.0), // mb-3

          // TSX: <div className="flex flex-wrap gap-2">
          // 'Wrap' 위젯이 'flex-wrap'을 구현합니다.
          Wrap(
            spacing: 8.0, // gap-2 (가로 간격)
            runSpacing: 8.0, // gap-2 (세로 간격)
            children: categories.map((category) {
              final String categoryKey = category.en.toLowerCase();
              final bool isSelected = (filter == categoryKey);

              // 'ChoiceChip'이 선택 가능한 버튼에 가장 적합합니다.
              return ChoiceChip(
                label: Text(category.get(language)),
                selected: isSelected,
                // TSX: onClick={() => setFilter(category.en.toLowerCase())}
                onSelected: (bool selected) {
                  if (selected) {
                    setFilter(categoryKey);
                  }
                },
                // --- 스타일링 ---
                // TSX: text-sm font-medium
                labelStyle: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  // TSX: bg-brand-accent text-white OR text-brand-text-primary
                  color: isSelected ? AppColors.textOnAccent : AppColors.textPrimary,
                ),
                // TSX: px-4 py-2
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                // TSX: rounded-full
                shape: const StadiumBorder(),
                // TSX: bg-brand-accent
                selectedColor: AppColors.brandAccent,
                // TSX: bg-gray-100
                backgroundColor: AppColors.gray100,
                // TSX: shadow-lg (선택 시)
                elevation: isSelected ? 3.0 : 0.0,
                pressElevation: 1.0,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}