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
          icon: Icon(Icons.map_outlined),
          label: 'Find Heroes',
          backgroundColor: Colors.blueAccent,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'My Jobs',
          backgroundColor: Colors.blueAccent,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none),
          label: 'Messages',
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
