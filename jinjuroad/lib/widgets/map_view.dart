import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../types.dart' as types;
import '../theme/colors.dart';

class _LatLng {
  final double lat;
  final double lng;
  _LatLng(this.lat, this.lng);
}

class _MarkerData {
  final String id;
  final _LatLng position;
  final String title;
  final String? snippet;
  _MarkerData({required this.id, required this.position, required this.title, this.snippet});
}

class MapView extends StatefulWidget {
  final List<types.Event> events;
  final types.Language language;
  final Function(types.Event) onSelect;
  final Map<String, String> uiText; // getUIText('viewDetails')

  const MapView({
    Key? key,
    required this.events,
    required this.language,
    required this.onSelect,
    required this.uiText,
  }) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  // 내부적으로 관리하는 마커 데이터 (google_maps_flutter 없이도 컴파일 되도록)
  List<_MarkerData> _markers = [];

  String _getUIText(String key) => widget.uiText[key] ?? key;

  @override
  void initState() {
    super.initState();
    _rebuildMarkers();
  }

  @override
  void didUpdateWidget(covariant MapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.events != widget.events || oldWidget.language != widget.language) {
      _rebuildMarkers();
    }
  }

  void _rebuildMarkers() {
    final List<_MarkerData> list = widget.events.map((e) {
      final pos = _LatLng(e.location.lat, e.location.lng);
      return _MarkerData(
        id: 'event_${e.id}',
        position: pos,
        title: e.title.get(widget.language),
        snippet: '${e.category.get(widget.language)} - ${_getUIText('tapForDetails')}',
      );
    }).toList();

    setState(() => _markers = list);
  }

  Widget _buildPlaceholderMap() {
    // non-Android: 간단한 대체 UI (map area + markers 리스트)
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.45,
          width: double.infinity,
          color: Colors.grey[200],
          child: Center(
            child: Text('지도는 Android에서 Kakao Map 네이티브로 표시됩니다.',
                style: TextStyle(color: Colors.grey[700])),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _markers.isEmpty
              ? Center(child: Text('표시할 이벤트가 없습니다.'))
              : ListView.separated(
            itemCount: _markers.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, idx) {
              final m = _markers[idx];
              return ListTile(
                title: Text(m.title),
                subtitle: Text('${m.position.lat.toStringAsFixed(5)}, ${m.position.lng.toStringAsFixed(5)}'),
                trailing: TextButton(
                  onPressed: () {
                    // find corresponding event and call onSelect
                    final ev = widget.events.firstWhere((e) => 'event_${e.id}' == m.id, orElse: () => widget.events.first);
                    widget.onSelect(ev);
                  },
                  child: Text(_getUIText('viewDetails')),
                ),
                onTap: () {
                  final ev = widget.events.firstWhere((e) => 'event_${e.id}' == m.id, orElse: () => widget.events.first);
                  widget.onSelect(ev);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAndroid = defaultTargetPlatform == TargetPlatform.android;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.brandSecondary,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: isAndroid
              ? Stack(
            children: [
              // Android 네이티브 Kakao Map (네이티브 구현이 필요)
              AndroidView(
                viewType: 'kakao_map_view',
                layoutDirection: TextDirection.ltr,
                creationParams: {}, // 필요 시 옵션 전달
                creationParamsCodec: const StandardMessageCodec(),
              ),
              // 간단한 오버레이: 이벤트가 없을 때 안내 표시
              if (_markers.isEmpty)
                Positioned.fill(
                  child: Container(
                    color: Colors.black12,
                    child: Center(
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text('이벤트가 없거나 네이티브 맵이 준비되지 않았습니다.'),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          )
              : _buildPlaceholderMap(),
        ),
      ),
    );
  }
}