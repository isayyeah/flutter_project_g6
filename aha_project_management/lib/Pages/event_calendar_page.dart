import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Event Calendar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EventCalendarPage(),
    );
  }
}

class Event {
  final String title;
  final String description;
  final DateTime date;

  Event({required this.title, required this.description, required this.date});
}

class EventCalendarPage extends StatefulWidget {
  @override
  _EventCalendarPageState createState() => _EventCalendarPageState();
}

class _EventCalendarPageState extends State<EventCalendarPage> {
  late DateTime _selectedDate;
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadEvents();
  }

  void _loadEvents() {
    // Simulate loading events from a data source
    // In a real app, you would fetch events from a database or an API
    _events = [
      Event(
        title: 'Event 1',
        description: 'Description 1',
        date: DateTime.now().add(Duration(hours: 1)),
      ),
      Event(
        title: 'Event 2',
        description: 'Description 2',
        date: DateTime.now().add(Duration(hours: 2)),
      ),
      Event(
        title: 'Event 3',
        description: 'Description 3',
        date: DateTime.now().add(Duration(days: 1, hours: 3)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Simple Event Calendar'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildCalendar(),
          _buildEventList(),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: EdgeInsets.all(16.0),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2025, 12, 31),
        focusedDay: _selectedDate,
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDate = selectedDay;
          });
        },
      ),
    );
  }

  Widget _buildEventList() {
    final selectedEvents = _events
        .where((event) =>
            event.date.year == _selectedDate.year &&
            event.date.month == _selectedDate.month &&
            event.date.day == _selectedDate.day)
        .toList();

    return Expanded(
      child: ListView.builder(
        itemCount: selectedEvents.length,
        itemBuilder: (context, index) {
          final event = selectedEvents[index];
          return ListTile(
            title: Text(event.title),
            subtitle: Text(event.description),
            onTap: () {
              // Handle tapping on an event for more details or navigation
              print('Tapped on ${event.title}');
            },
          );
        },
      ),
    );
  }
}
