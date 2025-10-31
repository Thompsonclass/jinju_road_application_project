import 'package:flutter/material.dart';
import '../types.dart';
import '../theme/colors.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final Language language;
  final Function(Event) onSelect;

  const EventCard({
    Key? key,
    required this.event,
    required this.language,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TSX: hover:-translate-y-2, hover:shadow-xl
    // Card 위젯이 shadow-md를 기본적으로 처리합니다.
    // InkWell이 탭 효과를 제공합니다.
    return Card(
      // TSX: rounded-lg overflow-hidden
      clipBehavior: Clip.antiAlias, // overflow-hidden
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0), // rounded-lg
        // TSX: border border-gray-200
        side: const BorderSide(
          color: AppColors.gray200,
          width: 1.0,
        ),
      ),
      // TSX: shadow-md
      elevation: 3.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0), // 카드 간 간격
      child: InkWell(
        // TSX: onClick={() => onSelect(event)}
        onTap: () => onSelect(event),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 이미지 및 오버레이 섹션 ---
            // TSX: <div className="relative">
            SizedBox(
              // TSX: h-48
              height: 192.0, // h-48
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // --- 이미지 ---
                  // TSX: <img src={event.image} ... className="w-full h-48 object-cover" />
                  // group-hover:scale-110은 모바일에서 구현하기 복잡하므로 생략합니다.
                  Image.network(
                    event.image,
                    fit: BoxFit.cover,
                    // 이미지 로딩 중/에러 시 표시할 위젯
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.brandAccent,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                  ),

                  // --- 그라데이션 오버레이 ---
                  // TSX: <div className="absolute inset-0 bg-gradient-to-t from-black/70 to-transparent"></div>
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7), // from-black/70
                          Colors.transparent, // to-transparent
                        ],
                      ),
                    ),
                  ),

                  // --- 오버레이 위 텍스트 ---
                  // TSX: <div className="absolute bottom-0 left-0 p-4">
                  Positioned(
                    bottom: 16.0,
                    left: 16.0,
                    right: 16.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- 카테고리 태그 ---
                        // TSX: <span className="inline-block bg-brand-accent text-white ...">
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, // px-3
                            vertical: 4.0, // py-1
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.brandAccent, // bg-brand-accent
                            borderRadius:
                            BorderRadius.circular(9999.0), // rounded-full
                          ),
                          child: Text(
                            event.category.get(language),
                            // TSX: text-xs font-semibold
                            style: const TextStyle(
                              color: AppColors.textOnAccent, // text-white
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0), // mt-2

                        // --- 제목 ---
                        // TSX: <h2 className="text-xl font-bold mt-2 text-white">
                        Text(
                          event.title.get(language),
                          style: const TextStyle(
                            color: Colors.white, // text-white
                            fontSize: 20.0, // text-xl
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- 날짜 섹션 ---
            // TSX: <div className="p-4 bg-brand-secondary">
            Padding(
              padding: const EdgeInsets.all(16.0), // p-4
              // bg-brand-secondary는 Card의 기본 배경색(흰색)으로 처리
              child: Text(
                event.date.get(language),
                // TSX: text-sm text-brand-text-secondary
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}