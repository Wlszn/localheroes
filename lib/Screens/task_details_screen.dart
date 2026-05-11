import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Models/task_model.dart';
import '../Models/user_model.dart';

class TaskDetailsScreen extends StatelessWidget {
  final TaskModel task;

  const TaskDetailsScreen({
    super.key,
    required this.task,
  });

  String _formatDate(DateTime dateTime) =>
      DateFormat('EEEE, MMMM d').format(dateTime);

  String _formatTime(DateTime dateTime) =>
      DateFormat('h:mm a').format(dateTime);

  Future<UserModel?> _getHeroUser() async {
    if (task.heroId == null || task.heroId!.isEmpty) {
      return null;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: task.heroId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return UserModel.fromDocument(snapshot.docs.first);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              'Job Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                task.categoryId,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF155DFC),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMainJobCard(),
          const SizedBox(height: 18),
          _buildStatusCard(),
          const SizedBox(height: 18),

          if (task.status == Status.assigned) ...[
            _buildAcceptedByCard(),
            const SizedBox(height: 18),
          ],

          _buildPostedByCard(),
          const SizedBox(height: 18),
          _buildMapCard(),
          const SizedBox(height: 18),
          _buildDescriptionCard(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMainJobCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101828),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${task.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00A63E),
                    ),
                  ),
                  const Text(
                    'Budget',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6A7282)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _infoBox(
                  icon: Icons.calendar_today,
                  iconColor: const Color(0xFF2563EB),
                  iconBg: const Color(0xFFDBEAFE),
                  label: 'Date',
                  value: _formatDate(task.deadline),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoBox(
                  icon: Icons.access_time,
                  iconColor: const Color(0xFF9810FA),
                  iconBg: const Color(0xFFF3E8FF),
                  label: 'Time',
                  value: _formatTime(task.deadline),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _infoBox(
            icon: Icons.location_on_outlined,
            iconColor: const Color(0xFF00A63E),
            iconBg: const Color(0xFFDCFCE7),
            label: 'Location',
            value: task.location,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    String statusText;
    Color statusColor;
    Color backgroundColor;

    switch (task.status) {
      case Status.open:
        statusText = 'Open - waiting for a hero';
        statusColor = const Color(0xFF155DFC);
        backgroundColor = const Color(0xFFEFF6FF);
        break;
      case Status.assigned:
        statusText = 'Assigned - a hero accepted this task';
        statusColor = const Color(0xFF00A63E);
        backgroundColor = const Color(0xFFDCFCE7);
        break;
      case Status.completed:
        statusText = 'Completed';
        statusColor = const Color(0xFF6B7280);
        backgroundColor = const Color(0xFFF3F4F6);
        break;
      case Status.cancelled:
        statusText = 'Cancelled';
        statusColor = const Color(0xFFDC2626);
        backgroundColor = const Color(0xFFFEE2E2);
        break;
    }

    return _card(
      child: Row(
        children: [
          Icon(Icons.info_outline, color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              task.status.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptedByCard() {
    return FutureBuilder<UserModel?>(
      future: _getHeroUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _card(
            child: const Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 12),
                Text('Loading accepted hero...'),
              ],
            ),
          );
        }

        final hero = snapshot.data;

        return _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Accepted By',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF101828),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: Color(0xFF00A63E),
                    child: Icon(Icons.handyman, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hero?.name ?? 'Assigned Hero',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF101828),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          hero?.email ?? 'Hero accepted this task',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4A5565),
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'This hero is now responsible for the task',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6A7282),
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: const Text('Message'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPostedByCard() {
    return _card(
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Posted By',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF101828),
            ),
          ),
          SizedBox(height: 18),
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Color(0xFF155DFC),
                child: Icon(Icons.person, color: Colors.white, size: 28),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF101828),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Task Owner',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6A7282),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapCard() {
    final bool hasLocation = task.latitude != null && task.longitude != null;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location Map',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: hasLocation
                  ? null
                  : const LinearGradient(
                colors: [Color(0xFFDBEAFE), Color(0xFFF3E8FF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.hardEdge,
            child: hasLocation
                ? GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(task.latitude!, task.longitude!),
                zoom: 14,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('task_location'),
                  position: LatLng(task.latitude!, task.longitude!),
                  infoWindow: InfoWindow(
                    title: task.title,
                    snippet: task.location,
                  ),
                ),
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
            )
                : const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 48,
                  color: Color(0xFF9CA3AF),
                ),
                SizedBox(height: 8),
                Text(
                  'Map view of job location',
                  style: TextStyle(
                    color: Color(0xFF4A5565),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Task Description',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            task.description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4A5565),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.category_outlined,
                  size: 16, color: Color(0xFF6A7282)),
              const SizedBox(width: 6),
              Text(
                'Category: ${task.categoryId}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6A7282),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.attach_money,
                  size: 16, color: Color(0xFF6A7282)),
              const SizedBox(width: 6),
              Text(
                'Budget: \$${task.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6A7282),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _infoBox({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: iconBg,
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:
                  const TextStyle(fontSize: 12, color: Color(0xFF6A7282)),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101828),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}