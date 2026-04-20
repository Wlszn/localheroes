import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Controllers/task_controller.dart';
import '../Models/task_model.dart';
import 'post_task_screen.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen>
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
    return StreamBuilder<List<JobModel>>(
      stream: _taskController.getMyJobs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final allJobs = snapshot.data ?? [];

        final openJobs = allJobs
            .where((job) => job.status == Status.open)
            .toList();

        final assignedJobs = allJobs
            .where((job) => job.status == Status.assigned)
            .toList();

        final completedJobs = allJobs
            .where((job) => job.status == Status.completed)
            .toList();

        final cancelledJobs = allJobs
            .where((job) => job.status == Status.cancelled)
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
                          'My Jobs',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${allJobs.length} total jobs',
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
                            builder: (context) => const PostJobScreen(),
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
                      child: const Text('Post New Job'),
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
                      Tab(text: 'Open (${openJobs.length})'),
                      Tab(text: 'Assigned (${assignedJobs.length})'),
                      Tab(text: 'Completed (${completedJobs.length})'),
                      Tab(text: 'Cancelled (${cancelledJobs.length})'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildJobList(openJobs, 'No open tasks'),
                    _buildJobList(assignedJobs, 'No assigned tasks'),
                    _buildJobList(completedJobs, 'No completed tasks'),
                    _buildJobList(cancelledJobs, 'No cancelled tasks'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJobList(List<JobModel> jobs, String emptyMessage) {
    if (jobs.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(job.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.description),
                const SizedBox(height: 4),
                Text(
                  'Posted: ${DateFormat('MMM dd, yyyy - hh:mm a').format(job.createdAt)}',
                ),
                Text(
                  'Deadline: ${DateFormat('MMM dd, yyyy - hh:mm a').format(job.deadline)}',
                ),
              ],
            ),
            trailing: Text(_statusLabel(job.status)),
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
