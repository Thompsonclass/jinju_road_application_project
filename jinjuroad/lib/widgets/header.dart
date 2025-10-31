import 'package:flutter/material.dart';
import '../types.dart';
import '../theme/colors.dart';
import 'logo.dart';
import 'search_bar.dart';

// Header.tsx를 AppBar로 구현합니다.
// AppBar는 Scaffold의 'appBar' 속성에 사용됩니다.
class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Language language;
  final Function(Language) setLanguage;
  final Function(String) onSearch;
  final VoidCallback setViewToHome;

  const MainAppBar({
    Key? key,
    required this.language,
    required this.setLanguage,
    required this.onSearch,
    required this.setViewToHome,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TSX: bg-brand-primary/80 backdrop-blur-sm sticky top-0
    // AppBar는 기본적으로 sticky top이며,
    // 배경색과 그림자(elevation)를 설정합니다.
    return AppBar(
      // TSX: bg-brand-primary
      backgroundColor: AppColors.brandPrimary.withOpacity(0.9), // 80% 불투명도
      // TSX: shadow-sm border-b border-gray-200
      elevation: 1.0, // shadow-sm
      surfaceTintColor: Colors.transparent, // Material 3에서 스크롤 시 색상 변경 방지

      // TSX: h-20 (PreferredSizeWidget.preferredSize로 제어)

      // TSX: <button onClick={() => setView('home')} aria-label="Home">
      // 로고
      leadingWidth: 120, // 로고 너비 확보
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0), // container px-4
        child: InkWell(
          onTap: setViewToHome,
          borderRadius: BorderRadius.circular(8.0),
          child: const Center(
            child: Logo(size: 32.0),
          ),
        ),
      ),

      // TSX: <div className="flex-1 flex justify-center px-4">
      // 검색창 (AppBar의 'title' 영역을 검색창으로 사용)
      title: AppSearchBar(
        onSearch: onSearch,
        language: language,
      ),
      centerTitle: true, // 제목(검색창)을 중앙에 배치

      // TSX: <div className="flex items-center bg-gray-100 rounded-full p-1">
      // 언어 변경 버튼
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16.0), // container px-4
          padding: const EdgeInsets.all(4.0), // p-1
          decoration: BoxDecoration(
            color: AppColors.gray100, // bg-gray-100
            borderRadius: BorderRadius.circular(9999.0), // rounded-full
          ),
          child: Row(
            children: [
              _LanguageButton(
                label: 'KO',
                isSelected: language == Language.ko,
                onTap: () => setLanguage(Language.ko),
              ),
              _LanguageButton(
                label: 'EN',
                isSelected: language == Language.en,
                onTap: () => setLanguage(Language.en),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // TSX: h-20
  @override
  Size get preferredSize => const Size.fromHeight(80.0); // 높이 80 (h-20)
}

// 언어 변경 버튼 (Header.tsx 내부의 버튼 스타일)
class _LanguageButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // TSX: px-3 py-1 text-xs font-semibold rounded-full transition-colors...
    return Material(
      // 선택되었을 때만 색상 적용, 아니면 투명
      color: isSelected ? AppColors.brandAccent : Colors.transparent,
      borderRadius: BorderRadius.circular(9999.0), // rounded-full
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9999.0),
        child: Padding(
          // TSX: px-3 py-1
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          child: Text(
            label,
            style: TextStyle(
              // TSX: text-xs font-semibold
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              // TSX: bg-brand-accent text-white OR text-gray-500
              color: isSelected ? AppColors.textOnAccent : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}