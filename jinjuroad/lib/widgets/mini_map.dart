import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../types.dart' as types;

class _LatLng {
  final double lat;
  final double lng;
  _LatLng(this.lat, this.lng);
}

class MiniMap extends StatelessWidget {
  final types.Location location;

  const MiniMap({
    Key? key,
    required this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final _LatLng pos = _LatLng(location.lat, location.lng);

    if (isAndroid) {
      // Android 네이티브 Kakao Map의 작은 뷰 (네이티브 쪽에서 표시/마커 처리 필요)
      return SizedBox(
        height: 160,
        child: AndroidView(
          viewType: 'kakao_map_view', // 네이티브는 viewType 구분해서 작은 미니맵을 처리하도록 구현 권장
          layoutDirection: TextDirection.ltr,
          creationParams: {'lat': pos.lat, 'lng': pos.lng, 'zoom': 15.0},
          creationParamsCodec: const StandardMessageCodec(),
        ),
      );
    }

    // non-Android: 안전한 플레이스홀더 표시
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Container(
            width: 120,
            height: 120,
            color: Colors.grey[300],
            child: const Center(child: Icon(Icons.map, size: 40, color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(location.name.get(types.Language.ko), style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('위도: ${pos.lat.toStringAsFixed(5)}'),
                Text('경도: ${pos.lng.toStringAsFixed(5)}'),
                const Spacer(),
                Text('미니맵은 Android에서 Kakao Map으로 표시됩니다.', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }
}