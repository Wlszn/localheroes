import 'package:flutter/material.dart';
import '/widgets/bottom_navigation.dart';
import '/widgets/navigation_drawer.dart';
import 'job_list_screen.dart';
import 'find_heroes_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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
      drawer: Navigationdrawer(),

    );
  }
}
