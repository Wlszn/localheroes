import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Controllers/task_controller.dart';
import '../Models/task_model.dart';

class TaskDetailsScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final TaskController _taskController = TaskController();
  bool _isLoading = false;

  // Pull latest task from Firestore so status is always current
  late TaskModel _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  String get _currentUserId => _taskController.currentUserId ?? '';

  bool get _isHeroOfThisTask => _task.heroId == _currentUserId;

  bool get _isOpen => _task.status == Status.open;

  bool get _isAssignedToMe =>
      _task.status == Status.assigned && _isHeroOfThisTask;

  String _formatDate(DateTime dt) => DateFormat('EEEE, MMMM d').format(dt);

  String _formatTime(DateTime dt) => DateFormat('h:mm a').format(dt);

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  Future<void> _acceptTask() async {
    setState(() => _isLoading = true);
    try {
      await _taskController.acceptTask(_task.id);
      if (!mounted) return;
      setState(() {
        _task = TaskModel(
          id: _task.id,
          seekerId: _task.seekerId,
          title: _task.title,
          description: _task.description,
          categoryId: _task.categoryId,
          location: _task.location,
          price: _task.price,
          status: Status.assigned,
          createdAt: _task.createdAt,
          deadline: _task.deadline,
          latitude: _task.latitude,
          longitude: _task.longitude,
          heroId: _currentUserId,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task accepted! Check your Schedule tab.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_cleanError(e)), backgroundColor: Colors.orange),
      );
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _releaseTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Release Task?'),
        content: const Text(
          'This will make the task available for other heroes. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Release', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _taskController.releaseTask(_task.id);
      if (!mounted) return;
      setState(() {
        _task = TaskModel(
          id: _task.id,
          seekerId: _task.seekerId,
          title: _task.title,
          description: _task.description,
          categoryId: _task.categoryId,
          location: _task.location,
          price: _task.price,
          status: Status.open,
          createdAt: _task.createdAt,
          deadline: _task.deadline,
          latitude: _task.latitude,
          longitude: _task.longitude,
          heroId: null,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task released back to open.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cleanError(e)),
          backgroundColor: Colors.orange,
        ),
      );
    }
    if (mounted) setState(() => _isLoading = false);
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
                _task.categoryId,
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
          _buildStatusBanner(),
          const SizedBox(height: 12),
          _buildMainJobCard(),
          const SizedBox(height: 18),
          _buildPostedByCard(),
          const SizedBox(height: 18),
          _buildMapCard(),
          const SizedBox(height: 18),
          _buildDescriptionCard(),
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  /// Contextual status banner
  Widget _buildStatusBanner() {
    if (_isAssignedToMe) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF86EFAC)),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 18),
            SizedBox(width: 8),
            Text(
              'You have accepted this task',
              style: TextStyle(
                color: Color(0xFF15803D),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }
    if (_task.status == Status.assigned && !_isHeroOfThisTask) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF9C3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFDE047)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFFCA8A04), size: 18),
            SizedBox(width: 8),
            Text(
              'This task has already been accepted',
              style: TextStyle(
                color: Color(0xFF92400E),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }
    if (_task.status == Status.completed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          children: [
            Icon(Icons.task_alt, color: Color(0xFF6B7280), size: 18),
            SizedBox(width: 8),
            Text(
              'This task has been completed',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: _isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(),
              ),
            )
          : _buildActionButtons(),
    );
  }

  Widget _buildActionButtons() {
    // Hero has accepted this task → show Release
    if (_isAssignedToMe) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _releaseTask,
              icon: const Icon(Icons.undo, size: 16),
              label: const Text('Release Task'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      );
    }

    // Task is open → show Ask Question + Accept
    if (_isOpen) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Ask Question',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _acceptTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF155DFC),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Accept Job',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      );
    }

    // Assigned to someone else or completed → disabled
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          _task.status == Status.completed
              ? 'Task Completed'
              : 'Task Already Taken',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ── Detail cards (unchanged layout, real data) ────────────────────────────

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
                  _task.title,
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
                    '\$${_task.price.toStringAsFixed(0)}',
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
                  value: _formatDate(_task.deadline),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoBox(
                  icon: Icons.access_time,
                  iconColor: const Color(0xFF9810FA),
                  iconBg: const Color(0xFFF3E8FF),
                  label: 'Time',
                  value: _formatTime(_task.deadline),
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
            value: _task.location,
          ),
        ],
      ),
    );
  }

  Widget _buildPostedByCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Posted By',
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
                backgroundColor: Color(0xFF155DFC),
                child: Icon(Icons.person, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task Owner',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF101828),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Member',
                      style: TextStyle(fontSize: 13, color: Color(0xFF6A7282)),
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
  }

  Widget _buildMapCard() {
    final hasLocation = _task.latitude != null && _task.longitude != null;
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
                    ),
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.hardEdge,
            child: hasLocation
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_task.latitude!, _task.longitude!),
                      zoom: 14,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('task'),
                        position: LatLng(_task.latitude!, _task.longitude!),
                        infoWindow: InfoWindow(
                          title: _task.title,
                          snippet: _task.location,
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
            _task.description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4A5565),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.category_outlined,
                size: 16,
                color: Color(0xFF6A7282),
              ),
              const SizedBox(width: 6),
              Text(
                'Category: ${_task.categoryId}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF6A7282)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.attach_money,
                size: 16,
                color: Color(0xFF6A7282),
              ),
              const SizedBox(width: 6),
              Text(
                'Budget: \$${_task.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF6A7282)),
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
            color: Colors.black,
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
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6A7282),
                  ),
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
