import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'widgets/header.dart';
import 'widgets/footer.dart';
import 'widgets/quick_nav.dart';
import 'widgets/hero_carousel.dart';
import 'widgets/filter_bar.dart';
import 'widgets/event_card.dart';
import 'widgets/event_detail.dart';
import 'widgets/map_view.dart';
import 'widgets/calendar_view.dart';
import 'widgets/route_planner.dart';
import 'types.dart' as types;
import 'theme/colors.dart';
import 'mock_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  runApp(const JinjuPearlApp());
}

class JinjuPearlApp extends StatelessWidget {
  const JinjuPearlApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '진주목걸이',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.brandAccent,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Pretendard', //pubspec.yaml에 폰트 추가 필요
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.brandAccent,
          primary: AppColors.brandAccent,
          secondary: AppColors.brandAccent,
          background: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1.0,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- 상태 관리 (TSX의 useState) ---
  types.Language _language = types.Language.ko;
  types.View _currentView = types.View.home;
  String _searchQuery = '';
  String _filter = 'all';

  //UI 텍스트
  //실제 앱에서는 별도 파일로 분리
  final Map<String, String> _uiTextKO = {
    'listView': '리스트 뷰',
    'mapView': '지도 뷰',
    'calendarView': '캘린더 뷰',
    'routePlannerView': '추천 루트',
    'filterByCategory': '카테고리별 필터',
    'appName': '진주목걸이',
    'share': '공유하기',
    'backToList': '목록으로',
    'details': '상세 정보',
    'location': '위치 및 날짜',
    'viewDetails': '상세보기',
    'tapForDetails': '탭하여 상세보기',
    'selectAnEvent': '이벤트를 선택하세요',
    'generateRoutes': '추천 루트 생성',
    'generating': '생성 중...',
    'generatingRoutes': 'AI 루트 생성 중...',
    'selectRoute': '루트 선택',
    'mockRouteDisclaimer': 'AI가 생성한 추천 루트입니다.',
    'selectedRoute': '선택된 루트',
    'pointsOfInterest': '주요 장소 (POI)',
    'noEventsOnThisDay': '이 날짜에 이벤트가 없습니다.',
    'shareFailed': '공유에 실패했습니다.',
  };

  final Map<String, String> _uiTextEN = {
    'listView': 'List View',
    'mapView': 'Map View',
    'calendarView': 'Calendar View',
    'routePlannerView': 'Route Planner',
    'filterByCategory': 'Filter by Category',
    'appName': 'Jinju Pearl',
    'share': 'Share',
    'backToList': 'Back to List',
    'details': 'Details',
    'location': 'Location & Date',
    'viewDetails': 'View Details',
    'tapForDetails': 'Tap for details',
    'selectAnEvent': 'Select an Event',
    'generateRoutes': 'Generate Routes',
    'generating': 'Generating...',
    'generatingRoutes': 'Generating AI Routes...',
    'selectRoute': 'Select a Route',
    'mockRouteDisclaimer': 'Mock AI-generated routes.',
    'selectedRoute': 'Selected Route',
    'pointsOfInterest': 'Points of Interest (POI)',
    'noEventsOnThisDay': 'No events on this day.',
    'shareFailed': 'Failed to share.',
  };

  Map<String, String> get _currentUiText =>
      _language == types.Language.ko ? _uiTextKO : _uiTextEN;

  String _getUIText(String key) => _currentUiText[key] ?? key;

  //상태 변경 함수
  void _setLanguage(types.Language lang) {
    setState(() => _language = lang);
  }

  void _setView(types.View view) {
    setState(() {
      _currentView = view;
      _searchQuery = ''; //뷰 이동 시 검색 쿼리 초기화
    });
  }

  void _setFilter(String filter) {
    setState(() => _filter = filter);
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      //검색 시 자동으로 리스트 뷰로 전환
      _currentView = types.View.list;
      _filter = 'all'; //검색 시 필터 초기화
    });
  }

  void _onSelectEvent(types.Event event) {
    //EventDetail.tsx의 기능을 모달로 호출
    showEventDetailModal(
      context,
      event: event,
      language: _language,
      uiText: _currentUiText,
    );
  }

  //데이터 필터링(TSX의 useMemo)
  List<types.Event> get _filteredEvents {
    final List<types.Event> allEvents = MockData.events;

    //1.검색 쿼리 필터
    List<types.Event> events = allEvents.where((event) {
      if (_searchQuery.isEmpty) return true;
      return event.title.get(_language).toLowerCase().contains(_searchQuery) ||
          event.description.get(_language).toLowerCase().contains(_searchQuery);
    }).toList();

    //2.카테고리 필터
    events = events.where((event) {
      if (_filter == 'all') return true;
      return event.category.en.toLowerCase() == _filter;
    }).toList();

    return events;
  }

  //위젯 빌드
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //1.헤더(Header.tsx)
      appBar: MainAppBar(
        language: _language,
        setLanguage: _setLanguage,
        onSearch: _onSearch,
        setViewToHome: () => _setView(types.View.home),
      ),

      //2.메인 콘텐츠(스크롤 가능)
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            children: [
              //3. 현재 뷰에 따라 다른 위젯 렌더링
              _buildCurrentView(),

              //4. 푸터(Footer.tsx)
              Footer(appName: _getUIText('appName')),
            ],
          ),
        ),
      ),
    );
  }

  //뷰 렌더링 로직
  Widget _buildCurrentView() {
    switch (_currentView) {
      case types.View.home:
        return _buildHomeView();
      case types.View.list:
        return _buildListView();
      case types.View.map:
        return _buildMapView();
      case types.View.calendar:
        return _buildCalendarView();
      case types.View.route:
        return _buildRoutePlannerView();
    }
  }

  //뷰:홈
  Widget _buildHomeView() {
    return Column(
      children: [
        HeroCarousel(
          //"추천" 이벤트만 필터링(임의의 로직)
          events: MockData.events.where((e) => e.id <= 3).toList(),
          onSelect: _onSelectEvent,
          language: _language,
        ),
        QuickNav(
          setView: _setView,
          uiText: _currentUiText,
        ),
      ],
    );
  }

  //뷰:리스트
  Widget _buildListView() {
    final events = _filteredEvents;

    return Column(
      children: [
        FilterBar(
          events: MockData.events, //필터 생성용(전체 이벤트)
          filter: _filter,
          setFilter: _setFilter,
          language: _language,
          title: _getUIText('filterByCategory'),
        ),
        const SizedBox(height: 24.0),

        //EventCard.tsx리스트
        if (events.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Text("검색 결과가 없습니다.", style: TextStyle(fontSize: 16.0)),
          )
        else
          ListView.builder(
            itemCount: events.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), //부모 스크롤 사용
            itemBuilder: (context, index) {
              return EventCard(
                event: events[index],
                onSelect: _onSelectEvent,
                language: _language,
              );
            },
          ),
      ],
    );
  }

  //뷰:지도
  Widget _buildMapView() {
    return MapView(
      events: _filteredEvents, //리스트 뷰와 동일한 필터링 적용
      onSelect: _onSelectEvent,
      language: _language,
      uiText: _currentUiText,
    );
  }

  //뷰:캘린더
  Widget _buildCalendarView() {
    return CalendarView(
      events: MockData.events, //캘린더는 전체 이벤트를 받음
      onSelect: _onSelectEvent,
      language: _language,
      uiText: _currentUiText,
    );
  }

  //뷰:루트 플래너
  Widget _buildRoutePlannerView() {
    return RoutePlanner(
      events: MockData.events, //루트 생성 기준이 될 이벤트 목록
      language: _language,
      uiText: _currentUiText,
    );
  }
}