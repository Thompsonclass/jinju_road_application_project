// lib/types.dart

// Language와 View는 간단한 enum으로 정의
enum Language { ko, en }
enum View { home, list, map, calendar, route }

// 다국어 텍스트를 위한 클래스
class LocalizedString {
  final String ko;
  final String en;

  LocalizedString({required this.ko, required this.en});

  // 언어에 맞는 텍스트를 반환하는 헬퍼 메서드
  String get(Language lang) {
    return lang == Language.ko ? ko : en;
  }
}

// Event.location
class Location {
  final LocalizedString name;
  final double lat;
  final double lng;

  Location({required this.name, required this.lat, required this.lng});
}

// Event
class Event {
  final int id;
  final LocalizedString title;
  final LocalizedString description;
  final LocalizedString category;
  final LocalizedString date; // 날짜는 우선 문자열로 처리 (CalendarView에서 파싱)
  final String image;
  final Location location;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.image,
    required this.location,
  });
}

// POI 카테고리
enum POICategory { restaurant, restroom, aed, attraction }

// POI (Point of Interest)
class POI {
  final String id;
  final LocalizedString name;
  final POICategory category;
  final Location location; // Location 클래스 재사용

  POI({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
  });
}

// Route
class Route {
  final String id;
  final LocalizedString name;
  final LocalizedString description;
  final String color; // 예: "#FF5733"
  final List<Location> path; // Location의 위도/경도만 사용

  Route({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.path,
  });
}