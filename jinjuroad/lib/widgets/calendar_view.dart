// lib/calendar_view.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../types.dart' as types;
import '../theme/colors.dart';
import 'icons.dart';

class CalendarView extends StatefulWidget {
  final List<types.Event> events;
  final Function(types.Event) onSelect;
  final types.Language language;
  final Map<String, String> uiText;

  const CalendarView({
    Key? key,
    required this.events,
    required this.onSelect,
    required this.language,
    required this.uiText,
  }) : super(key: key);

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  // [수정] 사용되지 않는 컨트롤러 제거
  // late final CalendarController _calendarController;

  late DateTime _focusedDay;
  DateTime? _selectedDay;
  List<types.Event> _selectedDayEvents = [];
  Map<DateTime, List<types.Event>> _eventsByDay = {};

  static const List<Color> _eventColors = [
    Colors.purple, Colors.green, Colors.blue, Colors.red,
    Colors.yellow, Colors.indigo, Colors.pink, Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    // [수정] 컨트롤러 초기화 제거
    // _calendarController = CalendarController();
    _focusedDay = DateTime.utc(2025, 10, 1);
    _selectedDay = _focusedDay;
    _processEvents(widget.events);
  }

  Color _getColorForEvent(int eventId) {
    return _eventColors[eventId % _eventColors.length];
  }

  DateTimeRange? _parseEventDateRange(String dateStrEn) {
    if (dateStrEn.toLowerCase().contains('every')) {
      return null;
    }
    try {
      if (dateStrEn.contains(' - ')) {
        final parts = dateStrEn.split(' - ');
        final String startPart = parts[0];
        final String endPart = parts[1];

        final String year = endPart.split(',').last.trim();
        final String startDateStr = '$startPart, $year';
        final String endDateStr = endPart;

        final DateFormat format = DateFormat("MMMM d, yyyy", "en_US");
        final DateTime startDate = format.parse(startDateStr);
        final DateTime endDate = format.parse(endDateStr);

        return DateTimeRange(start: startDate, end: endDate);
      }
    } catch (e) {
      debugPrint("Could not parse date: $dateStrEn, Error: $e");
    }
    return null;
  }

  void _processEvents(List<types.Event> events) {
    final newEventsByDay = <DateTime, List<types.Event>>{};

    for (final event in events) {
      final range = _parseEventDateRange(event.date.en);
      if (range != null) {
        for (var day = range.start;
        day.isBefore(range.end.add(const Duration(days: 1)));
        day = day.add(const Duration(days: 1))) {

          final normalizedDay = DateUtils.dateOnly(day);

          if (newEventsByDay[normalizedDay] == null) {
            newEventsByDay[normalizedDay] = [];
          }
          newEventsByDay[normalizedDay]!.add(event);
        }
      }
    }

    setState(() {
      _eventsByDay = newEventsByDay;
      if (_selectedDay != null) {
        _selectedDayEvents = _getEventsForDay(DateUtils.dateOnly(_selectedDay!));
      }
    });
  }

  @override
  void didUpdateWidget(covariant CalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.events != oldWidget.events) {
      _processEvents(widget.events);
    }
  }

  @override
  void dispose() {
    // [수정] 컨트롤러 dispose 제거
    // _calendarController.dispose();
    super.dispose();
  }

  String _getUIText(String key) {
    return widget.uiText[key] ?? key;
  }

  List<types.Event> _getEventsForDay(DateTime day) {
    return _eventsByDay[DateUtils.dateOnly(day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedDayEvents = _getEventsForDay(selectedDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.language == types.Language.ko ? 'ko_KR' : 'en_US';

    return Column(
      children: [
        Text(
          _getUIText('calendarView'),
          style: const TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24.0),

        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.brandSecondary,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: AppColors.gray200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildCalendarHeader(locale),
              TableCalendar<types.Event>(
                locale: locale,
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                headerVisible: false,

                eventLoader: _getEventsForDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: _onDaySelected,
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },

                calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      if (events.isEmpty) return null;
                      return Positioned(
                        bottom: 5,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: events.take(4).map((event) {
                            return Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 1.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getColorForEvent(event.id),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return Center(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.brandAccent,
                            shape: BoxShape.circle,
                          ),
                          width: 36,
                          height: 36,
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      return Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.brandAccent.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          width: 36,
                          height: 36,
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    }
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16.0),
        _buildEventList(),
      ],
    );
  }

  Widget _buildCalendarHeader(String locale) {
    void _onPrevMonth() {
      setState(() {
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
      });
    }
    void _onNextMonth() {
      setState(() {
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
      });
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(AppIcons.chevronLeft),
          onPressed: _onPrevMonth,
        ),
        Text(
          DateFormat.yMMMM(locale).format(_focusedDay),
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        IconButton(
          icon: const Icon(AppIcons.chevronRight),
          onPressed: _onNextMonth,
        ),
      ],
    );
  }

  Widget _buildEventList() {
    if (_selectedDayEvents.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          _getUIText('noEventsOnThisDay'),
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 16.0),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _selectedDayEvents.length,
      itemBuilder: (context, index) {
        final event = _selectedDayEvents[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: _getColorForEvent(event.id),
            radius: 5,
          ),
          title: Text(
            event.title.get(widget.language),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(event.category.get(widget.language)),
          onTap: () => widget.onSelect(event),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
        );
      },
    );
  }
}

// [수정] 충돌나는 이 클래스는 완전히 삭제되어 있어야 합니다.
/*
class CalendarController extends ValueNotifier<DateTime> {
  ...
}
*/