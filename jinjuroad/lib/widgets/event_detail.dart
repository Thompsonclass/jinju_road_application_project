import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // 공유 기능
import '../types.dart' as types;
import '../theme/colors.dart';
import 'icons.dart';
import 'mini_map.dart'; // MiniMap 임포트

/// [public]
/// TSX: <EventDetail ... />
/// 이벤트 상세 모달을 띄우는 함수
void showEventDetailModal(
    BuildContext context, {
      required types.Event event,
      required types.Language language,
      required Map<String, String> uiText,
    }) {
  // TSX: <div className="fixed inset-0 bg-black bg-opacity-70 ...">
  showDialog(
    context: context,
    // 다이얼로그 바깥의 어두운 영역 (scrim)
    barrierColor: Colors.black.withOpacity(0.7),
    builder: (BuildContext dialogContext) {
      // TSX: <div className="... flex items-center justify-center p-4">
      // Dialog 위젯이 자동으로 중앙 정렬을 수행합니다.
      return _EventDetailContent(
        event: event,
        language: language,
        uiText: uiText,
      );
    },
  );
}

/// [private]
/// 상세 뷰의 실제 UI
class _EventDetailContent extends StatelessWidget {
  final types.Event event;
  final types.Language language;
  final Map<String, String> uiText;

  const _EventDetailContent({
    required this.event,
    required this.language,
    required this.uiText,
  });

  String _getUIText(String key) {
    return uiText[key] ?? key;
  }

  // TSX: const handleShare = async () => { ... }
  void _handleShare(BuildContext context) async {
    final shareText =
        "${event.title.get(language)}\n${event.description.get(language)}";
    // TSX: url: window.location.href (여기서는 간단한 텍스트만 공유)

    try {
      // TSX: await navigator.share(shareData);
      await Share.share(
        shareText,
        subject: event.title.get(language), // 이메일 공유 시 제목
      );
    } catch (err) {
      // TSX: console.error("Couldn't share content", err);
      // (optional) 스낵바 등으로 에러 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getUIText('shareFailed'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TSX: <div className="relative bg-brand-secondary rounded-lg ... max-w-4xl w-full my-8">
    return Dialog(
      // Dialog의 기본 패딩 제거
      insetPadding: const EdgeInsets.all(16.0), // p-4
      // TSX: rounded-lg
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      // TSX: bg-brand-secondary
      backgroundColor: AppColors.brandSecondary,
      child: ConstrainedBox(
        // TSX: max-w-4xl (1024.0)
        constraints: const BoxConstraints(maxWidth: 1024.0),
        child: Stack(
          children: [
            // --- 스크롤 가능한 콘텐츠 ---
            // TSX: <div className="max-h-[90vh] overflow-y-auto">
            ConstrainedBox(
              constraints: BoxConstraints(
                // TSX: max-h-[90vh]
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildImageHeader(context),
                      _buildContentBody(context),
                    ],
                  ),
                ),
              ),
            ),

            // --- 공유/닫기 버튼 ---
            // TSX: <div className="absolute top-4 right-4 z-20 flex gap-2">
            Positioned(
              top: 16.0,
              right: 16.0,
              child: Row(
                children: [
                  // TSX: <button onClick={handleShare} ...>
                  _CircleIconButton(
                    icon: AppIcons.share,
                    label: _getUIText('share'),
                    onTap: () => _handleShare(context),
                  ),
                  const SizedBox(width: 8.0), // gap-2
                  // TSX: <button onClick={onClose} ...>
                  _CircleIconButton(
                    icon: AppIcons.close,
                    label: _getUIText('backToList'),
                    onTap: () => Navigator.of(context).pop(), // onClose
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 이미지 헤더 ---
  Widget _buildImageHeader(BuildContext context) {
    // TSX: <div className="relative h-64 md:h-96">
    return SizedBox(
      height: 300, // h-64~h-96 사이의 적절한 모바일 높이
      child: Stack(
        fit: StackFit.expand,
        children: [
          // TSX: <img src={event.image} ... />
          Image.network(
            event.image,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: AppColors.gray200),
          ),
          // TSX: <div className="absolute inset-0 bg-gradient-to-t from-black/60 ...">
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
              ),
            ),
          ),
          // TSX: <div className="absolute bottom-0 left-0 p-6 md:p-8">
          Positioned(
            bottom: 24.0, // p-6
            left: 24.0,
            right: 24.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TSX: <span className="inline-block bg-brand-accent ...">
                Container(
                  margin: const EdgeInsets.only(bottom: 8.0), // mb-2
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: AppColors.brandAccent,
                    borderRadius: BorderRadius.circular(9999.0),
                  ),
                  child: Text(
                    event.category.get(language),
                    style: const TextStyle(
                      color: AppColors.textOnAccent,
                      fontSize: 14.0, // text-sm
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // TSX: <h1 className="text-3xl md:text-5xl font-extrabold ...">
                Text(
                  event.title.get(language),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28.0, // text-3xl
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    shadows: [Shadow(blurRadius: 4.0, color: Colors.black54)],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 콘텐츠 본문 (설명 + 위치/지도) ---
  Widget _buildContentBody(BuildContext context) {
    // TSX: <div className="p-6 md:p-8">
    return Padding(
      padding: const EdgeInsets.all(24.0),
      // TSX: <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
      // 모바일에서는 Column, 넓은 화면에서는 Row로 처리
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 600; // md: 브레이크포인트

          final locationWidget = _buildLocationInfo(context);
          final detailsWidget = _buildDetailsInfo(context);

          if (isWide) {
            // 넓은 화면: Row (md:grid-cols-3)
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TSX: md:col-span-2
                Expanded(flex: 2, child: detailsWidget),
                const SizedBox(width: 32.0), // gap-8
                // TSX: <div> (col-span-1)
                Expanded(flex: 1, child: locationWidget),
              ],
            );
          } else {
            // 좁은 화면: Column (grid-cols-1)
            return Column(
              children: [
                detailsWidget,
                const SizedBox(height: 32.0), // gap-8
                locationWidget,
              ],
            );
          }
        },
      ),
    );
  }

  // --- (좌측) 상세 정보 ---
  Widget _buildDetailsInfo(BuildContext context) {
    // TSX: <div className="md:col-span-2">
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TSX: <h2 className="text-2xl font-bold ...">
        Text(
          _getUIText('details'),
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Divider(color: AppColors.brandAccent, thickness: 2.0, endIndent: 200.0),
        const SizedBox(height: 16.0), // mb-4
        // TSX: <p className="text-base text-brand-text-secondary ... whitespace-pre-wrap">
        Text(
          event.description.get(language),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16.0,
            height: 1.6, // leading-relaxed
          ),
          // TSX: whitespace-pre-wrap (Flutter의 Text는 \n을 자동으로 줄바꿈)
        ),
      ],
    );
  }

  // --- (우측) 위치 및 미니맵 ---
  Widget _buildLocationInfo(BuildContext context) {
    // TSX: <div> (col-span-1)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TSX: <h2 className="text-2xl font-bold ...">
        Text(
          _getUIText('location'),
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Divider(color: AppColors.brandAccent, thickness: 2.0, endIndent: 100.0),
        const SizedBox(height: 16.0), // mb-4

        // TSX: <p className="text-base font-semibold">
        Text(
          event.location.name.get(language),
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
        ),
        // TSX: <p className="text-sm text-brand-text-secondary">
        Text(
          event.date.get(language),
          style: const TextStyle(fontSize: 14.0, color: AppColors.textSecondary),
        ),

        // TSX: <div className="mt-4 rounded-lg overflow-hidden h-48 ...">
        Container(
          height: 192.0, // h-48
          width: double.infinity,
          margin: const EdgeInsets.only(top: 16.0),
          clipBehavior: Clip.antiAlias, // rounded-lg overflow-hidden
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: AppColors.gray200), // border
          ),
          child: MiniMap(location: event.location),
        ),
      ],
    );
  }
}

// --- 상단 아이콘 버튼 (내부 사용) ---
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // TSX: <button ... className="text-white bg-black/40 rounded-full p-2 ...">
    return Material(
      color: Colors.black.withOpacity(0.4), // bg-black/40
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0), // p-2
          child: Icon(
            icon,
            color: Colors.white, // text-white
            size: 24.0, // w-6 h-6
            semanticLabel: label,
          ),
        ),
      ),
    );
  }
}