// lib/mock_data.dart

import 'types.dart' as types;

// Spring Boot API가 완성되기 전까지 사용할 가짜 데이터입니다.
class MockData {
  static final List<types.Event> events = [
    types.Event(
      id: 1,
      title: types.LocalizedString(ko: '진주남강유등축제', en: 'Jinju Namgang Yudeung Festival'),
      description: types.LocalizedString(
        ko: '진주의 밤하늘을 수놓는 아름다운 유등의 향연. 남강 위에 띄워진 수천 개의 등불이 장관을 이룹니다.',
        en: 'A beautiful feast of lanterns embroidering the night sky of Jinju. Thousands of lanterns floating on the Namgang River create a spectacular view.',
      ),
      category: types.LocalizedString(ko: '축제', en: 'Festival'),
      date: types.LocalizedString(ko: '2025년 10월 3일 - 10월 10일', en: 'October 3 - October 10, 2025'),
      image: 'https://images.unsplash.com/photo-1541892234994-4336181b1f20?ixlib=rb-4.0.3&q=85&fm=jpg&crop=entropy&cs=srgb&w=1600',
      location: types.Location(
        name: types.LocalizedString(ko: '진주성 및 남강 일원', en: 'Jinju Fortress & Namgang River Area'),
        lat: 35.1931,
        lng: 128.0777,
      ),
    ),
    types.Event(
      id: 2,
      title: types.LocalizedString(ko: '리버나이트 진주 (토요일)', en: 'River Night Jinju (Saturday)'),
      description: types.LocalizedString(
        ko: '매주 토요일 밤, 남강변에서 펼쳐지는 야간 관광 프로그램. 캔들라이트 콘서트와 푸드트럭을 즐겨보세요.',
        en: 'A night tourism program held every Saturday night along the Namgang River. Enjoy candlelight concerts and food trucks.',
      ),
      category: types.LocalizedString(ko: '야간관광', en: 'Night Tour'),
      date: types.LocalizedString(ko: '매주 토요일', en: 'Every Saturday'),
      image: 'https://images.unsplash.com/photo-1531338610538-2518c2d4c33f?ixlib=rb-4.0.3&q=85&fm=jpg&crop=entropy&cs=srgb&w=1600',
      location: types.Location(
        name: types.LocalizedString(ko: '진주성 앞 남강둔치', en: 'Namgang Riverbank near Jinju Fortress'),
        lat: 35.1915,
        lng: 128.0792,
      ),
    ),
    types.Event(
      id: 3,
      title: types.LocalizedString(ko: '코리아 드라마 페스티벌', en: 'Korea Drama Festival'),
      description: types.LocalizedString(
        ko: '국내외 최고의 드라마 스타들을 만날 수 있는 기회. 다양한 드라마 관련 전시와 행사가 함께 열립니다.',
        en: 'A chance to meet the best drama stars from home and abroad. Various drama-related exhibitions and events are held together.',
      ),
      category: types.LocalizedString(ko: '공연/전시', en: 'Performance/Exhibition'),
      date: types.LocalizedString(ko: '2025년 10월 5일 - 10월 13일', en: 'October 5 - October 13, 2025'),
      image: 'https://images.unsplash.com/photo-1598899134739-24c46f58b8c0?ixlib=rb-4.0.3&q=85&fm=jpg&crop=entropy&cs=srgb&w=1600',
      location: types.Location(
        name: types.LocalizedString(ko: '경남문화예술회관', en: 'Gyeongnam Culture and Arts Center'),
        lat: 35.1895,
        lng: 128.0834,
      ),
    ),
    types.Event(
      id: 4,
      title: types.LocalizedString(ko: '진주 공예 비엔날레', en: 'Jinju Craft Biennale'),
      description: types.LocalizedString(
        ko: '전통과 현대를 아우르는 공예 작품들을 만나볼 수 있는 전시입니다. 장인의 숨결을 느껴보세요.',
        en: 'An exhibition where you can see craft works that span tradition and modernity. Feel the breath of artisans.',
      ),
      category: types.LocalizedString(ko: '공연/전시', en: 'Performance/Exhibition'),
      date: types.LocalizedString(ko: '2025년 11월 1일 - 11월 30일', en: 'November 1 - November 30, 2025'),
      image: 'https://images.unsplash.com/photo-1528461093121-7f9a11d8d4a6?ixlib=rb-4.0.3&q=85&fm=jpg&crop=entropy&cs=srgb&w=1600',
      location: types.Location(
        name: types.LocalizedString(ko: '진주시 일원', en: 'Throughout Jinju City'),
        lat: 35.1804,
        lng: 128.0831,
      ),
    ),
  ];
}