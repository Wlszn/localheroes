import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Controllers/task_controller.dart';
import '../../Models/task_model.dart';
import 'post_task_screen.dart';

//Task list screen that shows all available tasks that the user has made to the system.

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TaskController _taskController = TaskController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TaskModel>>(
      stream: _taskController.getMyTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final allTasks = snapshot.data ?? [];

        final openTasks = allTasks
            .where((task) => task.status == Status.open)
            .toList();

        final assignedTasks = allTasks
            .where((task) => task.status == Status.assigned)
            .toList();

        final completedTasks = allTasks
            .where((task) => task.status == Status.completed)
            .toList();

        final cancelledTasks = allTasks
            .where((task) => task.status == Status.cancelled)
            .toList();

        return Container(
          color: const Color(0xFFF3F4FB),
          child: Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(
                  top: 35,
                  right: 20,
                  bottom: 30,
                  left: 20,
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Tasks',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${allTasks.length} total tasks',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                    const Expanded(child: SizedBox()),
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PostTaskScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Post New Task'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Container(
                  height: 40,
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
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.white,
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.black54,
                    tabs: [
                      Tab(text: 'Open (${openTasks.length})'),
                      Tab(text: 'Assigned (${assignedTasks.length})'),
                      Tab(text: 'Completed (${completedTasks.length})'),
                      Tab(text: 'Cancelled (${cancelledTasks.length})'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTaskList(openTasks, 'No open tasks'),
                    _buildTaskList(assignedTasks, 'No assigned tasks'),
                    _buildTaskList(completedTasks, 'No completed tasks'),
                    _buildTaskList(cancelledTasks, 'No cancelled tasks'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskList(List<TaskModel> tasks, String emptyMessage) {
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(task.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.description),
                const SizedBox(height: 4),
                Text(
                  'Posted: ${DateFormat('MMM dd, yyyy - hh:mm a').format(task.createdAt)}',
                ),
                Text(
                  'Deadline: ${DateFormat('MMM dd, yyyy - hh:mm a').format(task.deadline)}',
                ),
              ],
            ),
            trailing: Text(_statusLabel(task.status)),
          ),
        );
      },
    );
  }

  String _statusLabel(Status status) {
    switch (status) {
      case Status.open:
        return 'Open';
      case Status.assigned:
        return 'Assigned';
      case Status.completed:
        return 'Completed';
      case Status.cancelled:
        return 'Cancelled';
    }
  }
}
