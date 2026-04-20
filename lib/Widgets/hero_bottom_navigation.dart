import 'package:flutter/material.dart';

class Bottomnavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const Bottomnavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.other_houses_rounded),
          label: 'Find Tasks',
          backgroundColor: Colors.blueAccent,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          label: 'Scheduled Tasks',
          backgroundColor: Colors.blueAccent,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.show_chart),
          label: 'Earnings',
          backgroundColor: Colors.blueAccent,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          label: 'Profile',
          backgroundColor: Colors.blueAccent,
        ),
      ],
      type: BottomNavigationBarType.shifting,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.black,
      elevation: 5,
    );
  }
}
