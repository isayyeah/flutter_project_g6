import 'package:aha_project_management/Pages/event_calendar_page.dart';
import 'package:aha_project_management/Pages/login_page.dart';

import 'package:aha_project_management/Services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:aha_project_management/Pages/home_page.dart';
import 'package:aha_project_management/Pages/task_page.dart';

class CustomNavBar extends StatefulWidget {
  final ValueChanged<int> onTabTapped;

  const CustomNavBar({Key? key, required this.onTabTapped}) : super(key: key);

  @override
  _CustomNavBarState createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  int _currentIndex = 0;

  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: _currentIndex,
      height: 50.0,
      color: Colors.purple,
      backgroundColor: Colors.white,
      items: <Widget>[
        Icon(Icons.home, size: 30),
        Icon(Icons.task, size: 30),
        Icon(Icons.calendar_month, size: 30),
        Icon(Icons.logout, size: 30),
      ],
      onTap: (index) {
        print('Index tapped: $index');
        // Handle navigation item taps here
        setState(() {
          _currentIndex = index;
        });

        // Notify the parent about the selected tab index
        widget.onTabTapped(index);

        // Navigate to different Dart pages based on the selected index
        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
            break;

          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskPage(),
              ),
            );
            break;
          //event calendar page

          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EventCalendarPage()),
            );
            break;

          case 3:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
              (Route<dynamic> route) => false,
            );

            break;
          default:
            break;
        }
      },
    );
  }
}
