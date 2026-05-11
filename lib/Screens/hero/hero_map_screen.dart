import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../Controllers/task_controller.dart';
import '../../Controllers/auth_controller.dart';
import '../../Models/task_model.dart';
import '../../Models/user_model.dart';
import '../task_details_screen.dart';
import '../Registration/role_screen.dart';

class HeroMapScreen extends StatefulWidget {
  const HeroMapScreen({super.key});

  @override
  State<HeroMapScreen> createState() => _HeroMapScreenState();
}

class _HeroMapScreenState extends State<HeroMapScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  bool _isLoadingLocation = true;
  String _locationText = 'Loading location...';

  Set<Marker> _markers = {};
  List<TaskModel> _tasks = [];

  UserModel? _heroProfile;
  bool _showProfile = false;

  final TaskController _taskController = TaskController();
  final AuthController _authController = AuthController();

  int _availableCount() {
    return _tasks.where((task) => task.status == Status.open).length;
  }

  int _acceptedCount() {
    return _tasks.where((task) => task.status == Status.assigned).length;
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
    _loadProfile();
    _listenToTasks();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _listenToTasks() {
    _taskController.getMapTasks().listen((tasks) {
      if (!mounted) return;
      setState(() => _tasks = tasks);
      _rebuildMarkers();
    });
  }

  Future<void> _loadProfile() async {
    final user = await _authController.getCurrentUserData();
    if (mounted) setState(() => _heroProfile = user);
  }

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location services')),
        );
      }
      return false;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
      }
      return false;
    }
    return true;
  }

  Future<void> _loadCurrentLocation() async {
    if (!mounted) return;
    setState(() => _isLoadingLocation = true);

    final ok = await _checkLocationPermission();
    if (!ok) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
          _locationText = 'Location unavailable';
        });
      }
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final newPos = LatLng(position.latitude, position.longitude);
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final place = placemarks.first;

      if (!mounted) return;
      setState(() {
        _currentPosition = newPos;
        _isLoadingLocation = false;
        _locationText =
            '${place.locality ?? ''}, ${place.administrativeArea ?? ''}';
      });

      _rebuildMarkers();
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: newPos, zoom: 13),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingLocation = false;
        _locationText = 'Location unavailable';
      });
    }
  }

  void _rebuildMarkers() {
    if (!mounted) return;

    final newMarkers = <Marker>{};

    for (final task in _tasks) {
      if (task.latitude == null || task.longitude == null) continue;

      final pos = LatLng(task.latitude!, task.longitude!);

      final distText = _currentPosition != null
          ? '${_distanceKm(_currentPosition!, pos).toStringAsFixed(1)} km · '
          : '';

      final isAvailable = task.status == Status.open;
      final isAccepted = task.status == Status.assigned;

      newMarkers.add(
        Marker(
          markerId: MarkerId(task.id),
          position: pos,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isAccepted ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(
            title: task.title,
            snippet: isAvailable
                ? 'Available · $distText\$${task.price.toStringAsFixed(0)} · ${task.categoryId}'
                : 'Accepted · $distText\$${task.price.toStringAsFixed(0)} · ${task.categoryId}',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TaskDetailsScreen(task: task)),
            ),
          ),
        ),
      );
    }

    setState(() => _markers = newMarkers);
  }

  double _distanceKm(LatLng a, LatLng b) {
    const r = 6371.0;
    final dLat = _deg2rad(b.latitude - a.latitude);
    final dLon = _deg2rad(b.longitude - a.longitude);
    final h =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(a.latitude)) *
            cos(_deg2rad(b.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return r * 2 * atan2(sqrt(h), sqrt(1 - h));
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  Future<void> _logout() async {
    await _authController.lopgoutUser();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Rolescreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            key: ValueKey(_currentPosition?.toString() ?? 'loading'),
            initialCameraPosition: CameraPosition(
              target: _currentPosition ?? const LatLng(0, 0),
              zoom: _currentPosition != null ? 13 : 2,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: _markers,
            onMapCreated: (c) {
              _mapController = c;
              if (_currentPosition != null) {
                c.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: _currentPosition!, zoom: 13),
                  ),
                );
              }
            },
          ),

          if (_isLoadingLocation)
            Container(
              color: Colors.white.withOpacity(0.6),
              child: const Center(child: CircularProgressIndicator()),
            ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: Color(0xFF155DFC),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _locationText,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Profile toggle button
                  GestureDetector(
                    onTap: () => setState(() => _showProfile = !_showProfile),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _showProfile
                            ? const Color(0xFF155DFC)
                            : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person,
                        color: _showProfile
                            ? Colors.white
                            : const Color(0xFF374151),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF155DFC),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.work_outline, color: Colors.white, size: 15),
                  const SizedBox(width: 6),
                  Text(
                    '${_availableCount()} available · ${_acceptedCount()} accepted',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            right: 16,
            bottom: _showProfile ? 360 : 30,
            child: FloatingActionButton.small(
              heroTag: 'locate',
              onPressed: _loadCurrentLocation,
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.my_location,
                color: Color(0xFF374151),
                size: 20,
              ),
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            bottom: _showProfile ? 0 : -340,
            left: 0,
            right: 0,
            child: _buildProfilePanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePanel() {
    final name = _heroProfile?.name ?? 'Hero';
    final email = _heroProfile?.email ?? '';
    final phone = _heroProfile?.phone ?? '';
    final verified = _heroProfile?.isVerifiedHero ?? false;

    return Container(
      height: 340,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
      ),
      child: Column(
        children: [
          // drag handle
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Avatar + name
          Row(
            children: [
              const SizedBox(width: 20),
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFF155DFC),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'H',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          verified ? Icons.verified : Icons.pending_outlined,
                          size: 15,
                          color: verified
                              ? const Color(0xFF00A63E)
                              : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          verified ? 'Verified Hero' : 'Pending Verification',
                          style: TextStyle(
                            fontSize: 13,
                            color: verified
                                ? const Color(0xFF00A63E)
                                : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          // Info rows
          _profileRow(Icons.email_outlined, email),
          _profileRow(
            Icons.phone_outlined,
            phone.isNotEmpty ? phone : 'No phone added',
          ),
          _profileRow(Icons.location_on_outlined, _locationText),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // Logout button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6B7280)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
