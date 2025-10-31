// dart
// 파일: `jinjuroad/lib/api/route_service.dart`
import 'dart:math';
import 'package:flutter/material.dart';
import '../types.dart' as types;

// 모의 API 호출입니다. 1초 지연 후 가짜 데이터를 반환합니다.
Future<Map<String, dynamic>> generateRoutes(types.Location eventLocation) async {
  await Future.delayed(const Duration(seconds: 1)); // isGenerating을 위한 딜레이

  final List<types.Route> routes = [];
  final List<types.POI> pois = [];
  final Random rand = Random();

  final List<Map<String, dynamic>> mockRoutesData = [
    {
      'id': 'route_1',
      'name': types.LocalizedString(ko: '역사 문화 코스', en: 'History & Culture Course'),
      'desc': types.LocalizedString(ko: '진주성의 역사를 따라 걷는 코스', en: 'A walk along the history of Jinju Fortress'),
      'color': '#FF5733',
    },
    {
      'id': 'route_2',
      'name': types.LocalizedString(ko: '리버 나이트 코스', en: 'River Night Course'),
      'desc': types.LocalizedString(ko: '남강의 야경을 즐기는 힐링 코스', en: 'A healing course to enjoy the night view'),
      'color': '#335BFF',
    },
  ];

  final List<Map<String, dynamic>> mockPOIData = [
    {'name': types.LocalizedString(ko: '진주성 맛집', en: 'Jinju Fortress Restaurant'), 'cat': types.POICategory.restaurant},
    {'name': types.LocalizedString(ko: '남강 공중화장실', en: 'Namgang Public Restroom'), 'cat': types.POICategory.restroom},
    {'name': types.LocalizedString(ko: '촉석루 제세동기', en: 'Chokseongnu AED'), 'cat': types.POICategory.aed},
    {'name': types.LocalizedString(ko: '국립진주박물관', en: 'Jinju National Museum'), 'cat': types.POICategory.attraction},
  ];

  // 가짜 경로 (Polyline) 생성
  for (var routeData in mockRoutesData) {
    List<types.Location> path = [];
    // google_maps_flutter LatLng 대신 types.Location으로 처리
    double curLat = eventLocation.lat;
    double curLng = eventLocation.lng;
    for (int i = 0; i < 5; i++) {
      curLat = curLat + (rand.nextDouble() - 0.5) * 0.01;
      curLng = curLng + (rand.nextDouble() - 0.5) * 0.01;
      path.add(types.Location(name: types.LocalizedString(ko: '', en: ''), lat: curLat, lng: curLng));
    }
    routes.add(
      types.Route(
        id: routeData['id'],
        name: routeData['name'],
        description: routeData['desc'],
        color: routeData['color'],
        path: path,
      ),
    );
  }

  // 가짜 POI (Markers) 생성
  for (var poiData in mockPOIData) {
    pois.add(
      types.POI(
        id: 'poi_${rand.nextInt(1000)}',
        name: poiData['name'],
        category: poiData['cat'],
        location: types.Location(
          name: poiData['name'],
          lat: eventLocation.lat + (rand.nextDouble() - 0.5) * 0.02,
          lng: eventLocation.lng + (rand.nextDouble() - 0.5) * 0.02,
        ),
      ),
    );
  }

  return {'routes': routes, 'pois': pois};
}
