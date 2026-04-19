import 'package:flutter/material.dart';
import 'package:localheroes/Screens/find_heroes_screen.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F4FB),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(top: 35, right: 20, bottom: 30, left: 20),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FindHeroesScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.arrow_back),
                ),

                SizedBox(width: 10),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Jobs',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '6 total jobs',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),

                // This creates space by taking available space to keep the button on the right side
                Expanded(child: SizedBox()),

                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Post New Job'),
                ),
              ],
            ),
          ),

          // SizedBox(height: 10),

          // Manual TabBar inside a Container
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: EdgeInsets.all(4),
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.white,
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.black54,
                    labelPadding: EdgeInsets.zero,
                    tabs: [
                      Tab(text: 'Open (4)'),
                      Tab(text: 'In Progress (1)'),
                      Tab(text: 'Completed (1)'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // TabBarView to show content of each tab by filling the remaining space inside Column
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Center(
                  child: Text(
                    'Open Tasks',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                  ),
                ),
                Center(
                  child: Text(
                    'In Progress Tasks',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                  ),
                ),
                Center(
                  child: Text(
                    'Completed Tasks',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
