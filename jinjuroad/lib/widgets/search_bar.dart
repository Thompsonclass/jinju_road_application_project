// lib/widgets/search_bar.dart

import 'package:flutter/material.dart';
import '../types.dart'; // Language enum
import '../theme/colors.dart'; // AppColors
import 'icons.dart'; // AppIcons

class AppSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final Language language;

  const AppSearchBar({
    Key? key,
    required this.onSearch,
    required this.language,
  }) : super(key: key);

  @override
  _AppSearchBarState createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  // 텍스트 필드의 입력을 제어하기 위한 컨트롤러
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    // onSearch 콜백을 호출하고, 키보드를 숨깁니다.
    widget.onSearch(_controller.text);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    String placeholderText = widget.language == Language.ko
        ? '축제 또는 이벤트를 검색하세요...'
        : 'Search for festivals or events...';

    // TSX의 스타일을 InputDecoration으로 변환
    const outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(9999.0)), // rounded-full
      borderSide: BorderSide(
        color: AppColors.gray300, // border-gray-300
        width: 2.0,
      ),
    );

    const focusedOutlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(9999.0)),
      borderSide: BorderSide(
        color: AppColors.brandAccent, // focus:ring-brand-accent
        width: 2.0,
      ),
    );

    return Container(
      // TSX: w-full max-w-lg (max-w-lg는 부모 위젯에서 제어)
      width: double.infinity,
      child: TextField(
        controller: _controller,
        // 키보드의 '검색' 또는 '완료' 버튼을 눌렀을 때
        onSubmitted: (value) => _handleSubmit(),
        decoration: InputDecoration(
          // TSX: placeholderText
          hintText: placeholderText,
          // TSX: bg-gray-100
          filled: true,
          fillColor: AppColors.gray100,

          // TSX: py-2 pl-4 pr-12
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10.0, // py-2
            horizontal: 16.0, // pl-4
          ),

          // TSX: pr-12를 대체하는 suffixIcon
          suffixIcon: IconButton(
            icon: const Icon(
              AppIcons.search,
              color: AppColors.textSecondary, // text-gray-500
            ),
            onPressed: _handleSubmit,
            splashRadius: 20.0,
            tooltip: 'Search',
          ),

          // 기본 테두리
          border: outlineInputBorder,
          // 활성화된 테두리 (포커스 없을 때)
          enabledBorder: outlineInputBorder,
          // 포커스되었을 때 테두리
          focusedBorder: focusedOutlineInputBorder,
        ),
      ),
    );
  }
}