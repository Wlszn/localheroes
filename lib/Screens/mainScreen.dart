import 'package:flutter/material.dart';
import 'package:localheroes/widgets/bottomNavigation.dart';
import 'homeScreen.dart';
import 'profileScreen.dart';
import 'taskScreen.dart';
import 'package:localheroes/widgets/NavigationDrawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  //index to switch between pages
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    Homescreen(),
    Profilescreen(),
    Taskscreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
      ),
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
