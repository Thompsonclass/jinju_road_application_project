// lib/widgets/quick_nav.dart

// 1. material.dart에서 'View'를 숨깁니다.
import 'package:flutter/material.dart' hide View;

// 2. 모든 import를 절대 경로로 수정합니다.
// (pubspec.yaml의 name: 값으로 변경하세요)
import 'package:jinju_tour_app/types.dart';
import 'package:jinju_tour_app/widgets/icons.dart';
import 'package:jinju_tour_app/theme/colors.dart';

class QuickNav extends StatelessWidget {
  // 이제 'View'는 types.dart의 enum을 명확히 가리킵니다.
  final Function(View) setView;
  final Map<String, String> uiText;

  const QuickNav({
    Key? key,
    required this.setView,
    required this.uiText,
  }) : super(key: key);

  String _getUIText(String key) {
    return uiText[key] ?? key; // 텍스트가 없으면 키 값을 반환
  }

  @override
  Widget build(BuildContext context) {
    // TSX: <div className="... my-8 py-8 bg-gray-50/50 rounded-lg">
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 32.0), // my-8
      padding: const EdgeInsets.symmetric(vertical: 32.0), // py-8
      decoration: BoxDecoration(
        color: AppColors.gray50.withOpacity(0.5), // bg-gray-50/50
        borderRadius: BorderRadius.circular(8.0), // rounded-lg
      ),
      // TSX: <div className="flex justify-center items-center ...">
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // justify-center gap-4 md:gap-12
        children: [
          _NavItem(
            icon: AppIcons.list,
            label: _getUIText('listView'),
            onClick: () => setView(View.list),
          ),
          _NavItem(
            icon: AppIcons.map,
            label: _getUIText('mapView'),
            onClick: () => setView(View.map),
          ),
          _NavItem(
            icon: AppIcons.calendar,
            label: _getUIText('calendarView'),
            onClick: () => setView(View.calendar),
          ),
          _NavItem(
            icon: AppIcons.route,
            label: _getUIText('routePlannerView'),
            onClick: () => setView(View.route),
          ),
        ],
      ),
    );
  }
}

// NavItem: React.FC ...
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onClick;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    // TSX: <button onClick={onClick} className="flex flex-col items-center ...">
    // InkWell과 Column을 사용해 버튼을 만듭니다.
    return InkWell(
      onTap: onClick,
      borderRadius: BorderRadius.circular(16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0), // 클릭 영역 확보
        child: Column(
          children: [
            // --- 아이콘 서클 ---
            // TSX: <div className="w-16 h-16 bg-brand-secondary rounded-full ...">
            Container(
              width: 64.0, // w-16
              height: 64.0, // h-16
              decoration: BoxDecoration(
                color: AppColors.brandSecondary, // bg-brand-secondary
                shape: BoxShape.circle, // rounded-full
                border: Border.all(color: AppColors.gray200, width: 2.0),
                boxShadow: const [ // shadow
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              // TSX: ... group-hover:bg-brand-accent ...
              // (Flutter의 InkWell은 hover 시 피드백을 자동으로 처리합니다)
              child: Center(
                // TSX: <div className="text-brand-text-secondary group-hover:text-white ...">
                child: Icon(
                  icon,
                  size: 32.0, // w-8 h-8
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 8.0), // space-y-2

            // --- 라벨 ---
            // TSX: <span className="text-sm font-medium text-brand-text-secondary ...">
            Text(
              label,
              style: const TextStyle(
                fontSize: 14.0, // text-sm
                fontWeight: FontWeight.w500, // font-medium
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}