import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../types.dart';
import 'icons.dart';
import '../theme/colors.dart';

class HeroCarousel extends StatefulWidget {
  final List<Event> events;
  final Function(Event) onSelect;
  final Language language;

  const HeroCarousel({
    Key? key,
    required this.events,
    required this.onSelect,
    required this.language,
  }) : super(key: key);

  @override
  _HeroCarouselState createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  int _currentIndex = 0;
  // carousel_slider의 컨트롤러 (새 API 타입)
  final CarouselSliderController _controller = CarouselSliderController();

  void _goToPrevious() {
    _controller.previousPage();
  }

  void _goToNext() {
    _controller.nextPage();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.events.isEmpty) {
      return const SizedBox(
          height: 200, child: Center(child: Text("No featured events.")));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0), // rounded-lg
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // --- 캐러셀 슬라이더 ---
            CarouselSlider.builder(
              carouselController: _controller,
              itemCount: widget.events.length,
              itemBuilder: (context, index, realIndex) {
                final event = widget.events[index];
                return _CarouselItem(
                  event: event,
                  language: widget.language,
                  onSelect: widget.onSelect,
                );
              },
              options: CarouselOptions(
                height: double.infinity,
                viewportFraction: 1.0,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 5),
                autoPlayAnimationDuration: const Duration(milliseconds: 1000),
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),

            // --- 좌/우 네비게이션 화살표 ---
            Positioned(
              left: 16.0,
              child: _NavArrow(
                icon: AppIcons.chevronLeft,
                onPressed: _goToPrevious,
                label: "Previous slide",
              ),
            ),
            Positioned(
              right: 16.0,
              child: _NavArrow(
                icon: AppIcons.chevronRight,
                onPressed: _goToNext,
                label: "Next slide",
              ),
            ),

            // --- 네비게이션 도트 ---
            Positioned(
              bottom: 32.0,
              right: 32.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.events.asMap().entries.map((entry) {
                  int index = entry.key;
                  return GestureDetector(
                    onTap: () => _controller.animateToPage(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _currentIndex == index ? 24.0 : 12.0,
                      height: 12.0,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9999.0),
                        color: _currentIndex == index
                            ? AppColors.brandAccent
                            : Colors.white.withOpacity(0.5),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 캐러셀 내부 아이템 (이미지, 그라데이션, 텍스트)
class _CarouselItem extends StatelessWidget {
  final Event event;
  final Language language;
  final Function(Event) onSelect;

  const _CarouselItem({
    required this.event,
    required this.language,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          event.image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Container(color: AppColors.gray200),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.black.withOpacity(0.4),
                Colors.transparent,
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
        ),
        Positioned(
          bottom: 32.0,
          left: 32.0,
          right: 32.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: AppColors.brandAccent,
                  borderRadius: BorderRadius.circular(9999.0),
                ),
                child: Text(
                  event.category.get(language),
                  style: const TextStyle(
                    color: AppColors.textOnAccent,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                event.title.get(language),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36.0,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  shadows: [
                    Shadow(blurRadius: 4.0, color: Colors.black54)
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16.0),
              FilledButton(
                onPressed: () => onSelect(event),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandAccent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 12.0),
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  language == Language.ko ? '자세히 보기' : 'Learn More',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 좌/우 화살표 버튼 위젯
class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String label;

  const _NavArrow({
    required this.icon,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.5),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24.0,
            semanticLabel: label,
          ),
        ),
      ),
    );
  }
}
