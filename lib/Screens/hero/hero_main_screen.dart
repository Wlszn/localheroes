import 'package:flutter/material.dart';
import '../../Widgets/hero_bottom_navigation.dart';
import 'find_tasks_page.dart';
import 'schedule_screen.dart';
import 'income_screen.dart';

//Main screen that handles the navigation of the hero side of the app

class HeroMainScreen extends StatefulWidget {
  const HeroMainScreen({super.key});

  @override
  State<HeroMainScreen> createState() => _HeroMainScreenState();
}

class _HeroMainScreenState extends State<HeroMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    FindTasksScreen(),

    IncomeScreen()


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