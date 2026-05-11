import 'package:flutter/material.dart';
import '../../Widgets/hero_bottom_navigation.dart';
import 'find_tasks_page.dart';
import 'schedule_screen.dart';
import 'income_screen.dart';
import 'hero_map_screen.dart';

class HeroMainScreen extends StatefulWidget {
  const HeroMainScreen({super.key});

  @override
  State<HeroMainScreen> createState() => _HeroMainScreenState();
}

class _HeroMainScreenState extends State<HeroMainScreen> {
  int _selectedIndex = 0;

  // Keep pages alive so map/stream state isn't lost on tab switch
  final List<Widget> _pages = const [
    FindTasksScreen(),
    ScheduleScreen(),
    IncomeScreen(),
    HeroMapScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Bottomnavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
