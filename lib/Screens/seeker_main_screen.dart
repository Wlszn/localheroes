import 'package:flutter/material.dart';
import '/widgets/seeker_bottom_navigation.dart';
import '/widgets/navigation_drawer.dart';
import 'seeker_tasklist_screen.dart';
import 'find_heroes_screen.dart';

class SeekerMainScreen extends StatefulWidget {
  const SeekerMainScreen({super.key});

  @override
  State<SeekerMainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<SeekerMainScreen> {
  //index to switch between pages
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    FindHeroesScreen(),
    JobListScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      _pages[_selectedIndex],
      bottomNavigationBar: Bottomnavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
