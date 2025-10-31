// dart
// 파일: `jinjuroad/lib/widgets/route_planner.dart`
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../types.dart' as types;
import '../theme/colors.dart';
import 'icons.dart';
import '../api/route_service.dart' as api; // 모의 API 임포트

// --- Google Maps 대체 스텁 타입들 (google_maps_flutter 미설치 시 컴파일 에러 방지) ---
// 실제 맵 SDK로 대체 가능. 현재는 UI/로직 동작을 위해 최소 필드만 구현.
class LatLng {
  final double latitude;
  final double longitude;
  LatLng(this.latitude, this.longitude);
}

class LatLngBounds {
  final LatLng southwest;
  final LatLng northeast;
  LatLngBounds({required this.southwest, required this.northeast});
}

class MarkerId {
  final String value;
  const MarkerId(this.value);
}

class Marker {
  final MarkerId markerId;
  final LatLng position;
  final InfoWindow? infoWindow;
  final dynamic icon;
  final double? zIndex;

  const Marker({
    required this.markerId,
    required this.position,
    this.infoWindow,
    this.icon,
    this.zIndex,
  });

  Marker copyWith({LatLng? positionParam}) {
    return Marker(
      markerId: markerId,
      position: positionParam ?? position,
      infoWindow: infoWindow,
      icon: icon,
      zIndex: zIndex,
    );
  }

  // convenience for using in Set equality
  @override
  bool operator ==(Object other) => other is Marker && other.markerId.value == markerId.value;
  @override
  int get hashCode => markerId.value.hashCode;
}

class InfoWindow {
  final String? title;
  final String? snippet;
  final VoidCallback? onTap;
  const InfoWindow({this.title, this.snippet, this.onTap});
}

class PolylineId {
  final String value;
  const PolylineId(this.value);
}

class Polyline {
  final PolylineId polylineId;
  final List<LatLng> points;
  final Color? color;
  final int? width;
  final Cap? startCap;
  final Cap? endCap;
  final JointType? jointType;

  const Polyline({
    required this.polylineId,
    required this.points,
    this.color,
    this.width,
    this.startCap,
    this.endCap,
    this.jointType,
  });

  @override
  bool operator ==(Object other) => other is Polyline && other.polylineId.value == polylineId.value;
  @override
  int get hashCode => polylineId.value.hashCode;
}

class BitmapDescriptor {
  static const double hueOrange = 30.0;
  static const double hueBlue = 240.0;
  static const double hueRed = 0.0;
  static const double hueViolet = 270.0;
  static const double hueAzure = 210.0;

  // stub: 실제 아이콘을 반환하지 않음
  static dynamic defaultMarkerWithHue(double hue) => hue;
}

enum Cap { roundCap }
enum JointType { round }

// 스텁 컨트롤러: 실제 GoogleMapController 대체. animateCamera 등은 noop.
class GoogleMapControllerStub {
  void animateCamera(dynamic update) {}
  void dispose() {}
}

// --- RoutePlanner 위젯 ---
class RoutePlanner extends StatefulWidget {
  final List<types.Event> events;
  final types.Language language;
  final Map<String, String> uiText; // getUIText

  const RoutePlanner({
    Key? key,
    required this.events,
    required this.language,
    required this.uiText,
  }) : super(key: key);

  @override
  _RoutePlannerState createState() => _RoutePlannerState();
}

class _RoutePlannerState extends State<RoutePlanner> {
  GoogleMapControllerStub? _mapController;

  bool _isGenerating = false;
  int? _selectedEventId;
  List<types.Route> _generatedRoutes = [];
  List<types.POI> _pointsOfInterest = [];
  types.Route? _selectedRoute;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  Marker? _userMarker;
  Timer? _animationTimer;

  static const Map<types.POICategory, IconData> _poiIcons = {
    types.POICategory.restaurant: AppIcons.restaurant,
    types.POICategory.restroom: AppIcons.restroom,
    types.POICategory.aed: AppIcons.aed,
    types.POICategory.attraction: AppIcons.attraction,
  };

  static const Map<types.POICategory, double> _poiMarkerHues = {
    types.POICategory.restaurant: BitmapDescriptor.hueOrange,
    types.POICategory.restroom: BitmapDescriptor.hueBlue,
    types.POICategory.aed: BitmapDescriptor.hueRed,
    types.POICategory.attraction: BitmapDescriptor.hueViolet,
  };

  @override
  void initState() {
    super.initState();
    if (widget.events.isNotEmpty) {
      _selectedEventId = widget.events.first.id;
    }
    _mapController = GoogleMapControllerStub(); // noop 컨트롤러
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  String _getUIText(String key) {
    return widget.uiText[key] ?? key;
  }

  void _clearMapObjects() {
    _animationTimer?.cancel();
    _animationTimer = null;

    setState(() {
      _polylines = {};
      _markers = {};
      _userMarker = null;
    });
  }

  Future<void> _handleGenerateRoutes() async {
    final event = widget.events.firstWhere((e) => e.id == _selectedEventId);
    // 실제 맵 컨트롤러가 필요하면 여기에 예외 처리 추가
    setState(() {
      _isGenerating = true;
      _selectedRoute = null;
    });
    _clearMapObjects();

    final result = await api.generateRoutes(event.location);
    final List<types.Route> routes = List<types.Route>.from(result['routes'] as List);
    final List<types.POI> pois = List<types.POI>.from(result['pois'] as List);

    final Set<Polyline> newPolylines = {};
    for (final route in routes) {
      newPolylines.add(
        Polyline(
          polylineId: PolylineId(route.id),
          points: route.path.map((loc) => LatLng(loc.lat, loc.lng)).toList(),
          color: Color(int.parse(route.color.replaceFirst('#', '0xFF'))),
          width: 6,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      );
    }

    setState(() {
      _generatedRoutes = routes;
      _pointsOfInterest = pois;
      _polylines = newPolylines;
      _isGenerating = false;
    });

    // 실제 맵에 맞추어 카메라를 이동시키려면 네이티브 코드와 통신 필요
    _fitMapToPolylines(newPolylines);
  }

  void _handleSelectRoute(types.Route route) {
    setState(() {
      _selectedRoute = route;
    });
    _clearMapObjects();

    final Set<Polyline> newPolylines = {};
    final Set<Marker> newMarkers = {};

    final routePoints = route.path.map((loc) => LatLng(loc.lat, loc.lng)).toList();
    newPolylines.add(
      Polyline(
        polylineId: PolylineId(route.id),
        points: routePoints,
        color: Color(int.parse(route.color.replaceFirst('#', '0xFF'))),
        width: 8,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    );

    for (final poi in _pointsOfInterest) {
      newMarkers.add(
        Marker(
          markerId: MarkerId(poi.id),
          position: LatLng(poi.location.lat, poi.location.lng),
          infoWindow: InfoWindow(title: poi.name.get(widget.language)),
          icon: BitmapDescriptor.defaultMarkerWithHue(_poiMarkerHues[poi.category] ?? BitmapDescriptor.hueAzure),
        ),
      );
    }

    setState(() {
      _polylines = newPolylines;
      _markers = newMarkers;
    });

    _fitMapToPolylines(newPolylines);
    _animateUserMarker(routePoints);
  }

  void _animateUserMarker(List<LatLng> path) {
    if (path.isEmpty) return;
    int step = 0;

    setState(() {
      _userMarker = Marker(
        markerId: const MarkerId('user_marker'),
        position: path[0],
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        zIndex: 1.0,
      );
    });

    _animationTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      step++;
      if (step >= path.length) step = 0;
      setState(() {
        _userMarker = _userMarker?.copyWith(positionParam: path[step]);
      });
    });
  }

  void _fitMapToPolylines(Set<Polyline> polylines) {
    if (polylines.isEmpty) return;
    // 실제 네이티브 맵에서는 카메라를 bounds에 맞춰 이동해야 함.
    // 현재는 noop 또는 네이티브 채널 구현 시 호출하도록 남겨둠.
  }

  LatLngBounds _boundsFromPolylines(Set<Polyline> polylines) {
    final List<LatLng> allPoints = [];
    for (var p in polylines) {
      allPoints.addAll(p.points);
    }
    if (allPoints.isEmpty) {
      return LatLngBounds(southwest: LatLng(0, 0), northeast: LatLng(0, 0));
    }

    double minLat = allPoints.first.latitude;
    double minLng = allPoints.first.longitude;
    double maxLat = allPoints.first.latitude;
    double maxLng = allPoints.first.longitude;

    for (var point in allPoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildControlPanel(),
            const SizedBox(height: 16.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 지도 영역 (가로 비율 2/3)
                Expanded(
                  flex: 2,
                  child: _buildMap(),
                ),
                const SizedBox(width: 16.0),
                // 사이드바 (가로 비율 1/3)
                Expanded(
                  flex: 1,
                  child: _buildSidebar(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.brandSecondary,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.gray200),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4.0)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<int>(
            value: _selectedEventId,
            items: widget.events.map((e) {
              return DropdownMenuItem<int>(
                value: e.id,
                child: Text(e.title.get(widget.language)),
              );
            }).toList(),
            onChanged: (v) => setState(() => _selectedEventId = v),
            decoration: const InputDecoration(labelText: '이벤트 선택'),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _isGenerating ? null : _handleGenerateRoutes,
            child: Text(_isGenerating ? '생성 중...' : '경로 생성'),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.brandSecondary,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.gray200),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4.0)],
      ),
      constraints: const BoxConstraints(maxHeight: 600),
      child: _selectedRoute == null ? _buildRouteSelectionList() : _buildSelectedRouteDetails(),
    );
  }

  Widget _buildRouteSelectionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getUIText('selectRoute'),
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: ListView.separated(
            itemCount: _generatedRoutes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8.0),
            itemBuilder: (context, index) {
              final r = _generatedRoutes[index];
              return _RouteSelectItem(
                route: r,
                language: widget.language,
                onTap: () => _handleSelectRoute(r),
                isSelected: _selectedRoute?.id == r.id,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedRouteDetails() {
    if (_selectedRoute == null) return Container();
    final route = _selectedRoute!;
    final sortedPOIs = List<types.POI>.from(_pointsOfInterest)
      ..sort((a, b) => a.category.index.compareTo(b.category.index));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(route.name.get(widget.language), style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8.0),
          Text(route.description.get(widget.language)),
          const SizedBox(height: 8.0),
          _RouteSelectItem(route: route, language: widget.language, isSelected: true),
          const SizedBox(height: 16.0),
          Text(_getUIText('pointsOfInterest'), style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8.0),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedPOIs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8.0),
            itemBuilder: (context, index) {
              final poi = sortedPOIs[index];
              return Row(
                children: [
                  Icon(_poiIcons[poi.category]),
                  const SizedBox(width: 8.0),
                  Expanded(child: Text(poi.name.get(widget.language))),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    // Android에서는 네이티브 Kakao Map으로 대체 (viewType: 'kakao_map_view')
    final bool isAndroid = defaultTargetPlatform == TargetPlatform.android;
    return SizedBox(
      height: 600,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Stack(
          children: [
            if (isAndroid)
              AndroidView(
                viewType: 'kakao_map_view',
                layoutDirection: TextDirection.ltr,
                creationParams: {},
                creationParamsCodec: const StandardMessageCodec(),
              )
            else
            // Android가 아니면 간단한 플레이스홀더 지도 UI 표시
              Container(
                color: Colors.grey[200],
                child: const Center(child: Text('지도는 Android에서 Kakao Map 네이티브로 표시됩니다.')),
              ),

            if (_isGenerating)
              Positioned.fill(
                child: Container(
                  color: Colors.black38,
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Generating AI Routes...'),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- 내부 위젯: RouteSelectItem ---
class _RouteSelectItem extends StatelessWidget {
  final types.Route route;
  final types.Language language;
  final VoidCallback? onTap;
  final bool isSelected;

  const _RouteSelectItem({
    required this.route,
    required this.language,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = Color(int.parse(route.color.replaceFirst('#', '0xFF')));

    return Material(
      color: isSelected ? AppColors.gray50 : Colors.transparent,
      borderRadius: BorderRadius.circular(6.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.0),
            border: Border(
              left: BorderSide(
                color: color,
                width: 4.0,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(route.name.get(language), style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(route.description.get(language), style: const TextStyle(fontSize: 14.0, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
