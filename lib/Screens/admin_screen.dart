import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localheroes/Screens/Registration/login_screen.dart';
import '../../Controllers/user_controller.dart';
import '../../Controllers/task_controller.dart';
import '../../Controllers/payment_controller.dart';
import '../../Models/user_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  final UserController _userController = UserController();
  final TaskController _taskController = TaskController();
  final PaymentController _paymentController = PaymentController();

  late TabController _tabController;

  int totalUsers = 0;
  int activeHeroes = 0;
  int jobsCompleted = 0;
  double totalRevenue = 0;

  List<UserModel> pendingHeroes = [];
  List<UserModel> allUsers = [];
  List<UserModel> filteredUsers = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      setState(() => loading = true);

      await Future.delayed(const Duration(seconds: 1));

      totalUsers = await _safe(() => _userController.countAllUsers(), 0);
      activeHeroes = await _safe(() => _userController.countActiveHeroes(), 0);
      jobsCompleted = await _safe(
        () => _taskController.countCompletedTasks(),
        0,
      );
      totalRevenue = await _safe(
        () => _paymentController.getTotalRevenue(),
        0.0,
      );

      pendingHeroes = await _safe(
        () => _userController.getPendingHeroVerifications(),
        <UserModel>[],
      );

      allUsers = await _safe(
        () => _userController.getAllUsers(),
        <UserModel>[],
      );

      filteredUsers = allUsers;
    } catch (e, stack) {
      print("UNEXPECTED DASHBOARD ERROR: $e");
      print(stack);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<T> _safe<T>(Future<T> Function() call, T fallback) async {
    try {
      return await call();
    } catch (e, stack) {
      print("ERROR in controller call: $e");
      print(stack);
      return fallback;
    }
  }

  void searchUser(String query) {
    if (query.isEmpty) {
      filteredUsers = allUsers;
    } else {
      filteredUsers = allUsers
          .where((u) => u.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    setState(() {});
  }

  Future<void> approveHero(UserModel user) async {
    await _userController.approveHero(user.uid);
    loadDashboardData();
  }

  Future<void> rejectHero(UserModel user) async {
    await _userController.rejectHero(user.uid);
    loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 3,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔥 PURPLE HEADER (NO GAP AT TOP)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 50, 16, 30),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔥 TITLE + SUBTITLE + LOGOUT IN ONE ROW (Figma accurate)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // LEFT SIDE: TITLE + SUBTITLE
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Admin Dashboard",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    "Manage users, verify heroes, monitor \nplatform",
                                    softWrap: true,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),

                              // RIGHT SIDE: LOGOUT BUTTON
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black87,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          LoginScreen(selectedRole: Role.admin),
                                    ),
                                  );
                                },
                                child: const Text("Logout"),
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          // 🔥 STAT CARDS (Figma style)
                          _statCard(
                            "Total Users",
                            totalUsers.toString(),
                            Icons.people_alt,
                            Colors.blue,
                            fullWidth: true,
                          ),
                          const SizedBox(height: 12),

                          _statCard(
                            "Active Heroes",
                            activeHeroes.toString(),
                            Icons.verified,
                            Colors.green,
                            fullWidth: true,
                          ),
                          const SizedBox(height: 12),

                          _statCard(
                            "Jobs Completed",
                            jobsCompleted.toString(),
                            Icons.check_circle,
                            Colors.orange,
                            fullWidth: true,
                          ),
                          const SizedBox(height: 12),

                          _statCard(
                            "Total Revenue",
                            "\$${totalRevenue.toStringAsFixed(2)}",
                            Icons.attach_money,
                            Colors.purple,
                            fullWidth: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔥 TAB BAR (Figma pill style)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicatorPadding: const EdgeInsets.all(4),
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.black54,
                          tabs: [
                            Tab(
                              child: Row(
                                children: [
                                  const Text("Pending Verifications"),
                                  if (pendingHeroes.isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(left: 6),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        pendingHeroes.length.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Tab(text: "All Users"),
                            const Tab(text: "Analytics"),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔥 TAB CONTENT (scrolls normally)
                    SizedBox(
                      height: 600,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _pendingTab(),
                          _allUsersTab(),
                          _analyticsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // UI COMPONENTS

  Widget _statCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pendingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: pendingHeroes.map((user) {
          return Card(
            child: ListTile(
              title: Text(user.name),
              subtitle: Column(children: [Text("${user.email} • hero")]),
              trailing: SizedBox(child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => approveHero(user),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      )
                    ),
                    label: const Text("Approve"),
                    icon: Icon(Icons.check_circle_outline),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => rejectHero(user),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)
                        )
                    ),
                    label: const Text("Reject"),
                    icon: Icon(CupertinoIcons.xmark_circle),
                  ),
                ],
              ),
            ),
            )
          );
        }).toList(),
      ),
    );
  }

  Widget _allUsersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            onChanged: searchUser,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: "Search users...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          ...filteredUsers.map((user) {
            return Card(
              child: ListTile(
                title: Text(user.name),
                subtitle: Text("${user.email} • ${user.role.name}"),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: const Text("View"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)
                    )
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _analyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _analyticsCard("Total Jobs Posted", "2891"),
          _analyticsCard("Completed Jobs", jobsCompleted.toString()),
          _analyticsCard("Active Jobs", "156"),
          _analyticsCard("Success Rate", "85%"),
          const SizedBox(height: 20),
          _analyticsCard(
            "Total Revenue",
            "\$${totalRevenue.toStringAsFixed(2)}",
          ),
          _analyticsCard("Average Job Value", "\$85"),
          _analyticsCard("Platform Fee (15%)", "\$21,851.7"),
          _analyticsCard("This Month", "\$24,890"),
        ],
      ),
    );
  }

  Widget _analyticsCard(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
