import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../Controllers/task_controller.dart';
import '../../Models/task_model.dart';
import '../task_details_screen.dart';
import '../settings_screen.dart';

class FindHeroesScreen extends StatefulWidget {
  const FindHeroesScreen({super.key});

  @override
  State<FindHeroesScreen> createState() => _FindHeroesScreenState();
}

class _FindHeroesScreenState extends State<FindHeroesScreen> {
  GoogleMapController? _mapController;
  String _locationText = 'Loading location...';

  // Null until GPS resolves — avoids the wrong-location jump
  LatLng? _currentPosition;
  bool _isLoadingLocation = true;
  bool _showListView = false;

  Set<Marker> _markers = {};
  List<TaskModel> _tasks = [];
  final TaskController _taskController = TaskController();

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
    _listenToTasks();
  }

  // ── Tasks ─────────────────────────────────────────────────────────────────

  void _listenToTasks() {
    _taskController.getAvailableTasks().listen((tasks) {
      if (!mounted) return;
      setState(() => _tasks = tasks);
      _rebuildMarkers();
    });
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

    final hasPermission = await _checkLocationPermission();

    if (!hasPermission) {
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

      // Convert coordinates into city/address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final place = placemarks.first;

      final city = place.locality ?? '';
      final province = place.administrativeArea ?? '';

      if (!mounted) return;

      setState(() {
        _currentPosition = newPos;
        _isLoadingLocation = false;
        _locationText = '$city, $province';
      });

      _rebuildMarkers();

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: newPos,
            zoom: 14,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingLocation = false;
        _locationText = 'Location unavailable';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  void _rebuildMarkers() {
    if (!mounted) return;
    final newMarkers = <Marker>{};

    for (final task in _tasks) {
      if (task.latitude == null || task.longitude == null) continue;
      final taskPos = LatLng(task.latitude!, task.longitude!);

      final distanceText = _currentPosition != null
          ? '${_distanceKm(_currentPosition!, taskPos).toStringAsFixed(1)} km away'
          : task.location;

      newMarkers.add(
        Marker(
          markerId: MarkerId(task.id),
          position: taskPos,
          infoWindow: InfoWindow(
            title: task.title,
            snippet: '\$${task.price.toStringAsFixed(0)} · $distanceText',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => TaskDetailsScreen(task: task)),
            ),
          ),
        ),
      );
    }

    setState(() => _markers = newMarkers);
  }

  double _distanceKm(LatLng a, LatLng b) {
    const earthR = 6371.0;
    final dLat = _deg2rad(b.latitude - a.latitude);
    final dLon = _deg2rad(b.longitude - a.longitude);
    final h = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(a.latitude)) *
            cos(_deg2rad(b.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return earthR * 2 * atan2(sqrt(h), sqrt(1 - h));
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  List<TaskModel> get _tasksSortedByDistance {
    if (_currentPosition == null) return _tasks;
    final sorted = [..._tasks];
    sorted.sort((a, b) {
      final da = (a.latitude != null && a.longitude != null)
          ? _distanceKm(
          _currentPosition!, LatLng(a.latitude!, a.longitude!))
          : double.infinity;
      final db = (b.latitude != null && b.longitude != null)
          ? _distanceKm(
          _currentPosition!, LatLng(b.latitude!, b.longitude!))
          : double.infinity;
      return da.compareTo(db);
    });
    return sorted;
  }

  void _goToProfile() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const SettingsScreen()),
  );

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _showListView ? _buildListView() : _buildMapView()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding:
      const EdgeInsets.only(left: 20, right: 20, bottom: 18, top: 10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find Heroes',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827)),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 16, color: Color(0xFF6B7280)),
                        SizedBox(width: 2),
                        Text( _locationText,
                            style: TextStyle(
                                fontSize: 14, color: Color(0xFF6B7280))),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_outlined,
                    size: 22, color: Color(0xFF111827)),
              ),
              IconButton(
                onPressed: _goToProfile,
                icon: const Icon(Icons.person_outline,
                    size: 22, color: Color(0xFF111827)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon:
                      Icon(Icons.search, color: Color(0xFF9CA3AF)),
                      hintText: 'Search by name or skill...',
                      hintStyle: TextStyle(
                          color: Color(0xFF9CA3AF), fontSize: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 46,
                height: 46,
                child: OutlinedButton(
                  onPressed: _loadCurrentLocation,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Icon(Icons.my_location,
                      color: Color(0xFF374151), size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        GoogleMap(
          key: ValueKey(_currentPosition?.toString() ?? 'loading'),
          initialCameraPosition: CameraPosition(
            target: _currentPosition ?? const LatLng(0, 0),
            zoom: _currentPosition != null ? 14 : 2,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          markers: _markers,
          onMapCreated: (controller) {
            _mapController = controller;
            // If GPS already resolved before the map widget was ready, jump there
            if (_currentPosition != null) {
              controller.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(target: _currentPosition!, zoom: 14),
                ),
              );
            }
          },
        ),
        if (_isLoadingLocation)
          Container(
            color: Colors.white.withOpacity(0.7),
            child: const Center(child: CircularProgressIndicator()),
          ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: ElevatedButton(
            onPressed: () => setState(() => _showListView = true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF111827),
              elevation: 2,
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child:
            const Text('View as List', style: TextStyle(fontSize: 15)),
          ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    final sorted = _tasksSortedByDistance;

    return Column(
      children: [
        // Toolbar
        Container(
          color: Colors.white,
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Expanded(
                child: Text('Tasks Near You',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold)),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _showListView = false),
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text('Map View'),
              ),
            ],
          ),
        ),
        Expanded(
          child: sorted.isEmpty
              ? const Center(
            child: Text('No available tasks nearby',
                style: TextStyle(
                    fontSize: 16, color: Color(0xFF4B5563))),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final task = sorted[index];
              final dist = (task.latitude != null &&
                  task.longitude != null &&
                  _currentPosition != null)
                  ? _distanceKm(_currentPosition!,
                  LatLng(task.latitude!, task.longitude!))
                  .toStringAsFixed(1)
                  : null;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            TaskDetailsScreen(task: task)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(task.title,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                      FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                task.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF4B5563)),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                      Icons.location_on_outlined,
                                      size: 14,
                                      color: Color(0xFF6B7280)),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      dist != null
                                          ? '$dist km · ${task.location}'
                                          : task.location,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color:
                                          Color(0xFF6B7280)),
                                      overflow:
                                      TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${task.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00A63E),
                              ),
                            ),
                            const Text('Budget',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6A7282))),
                            if (dist != null) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius:
                                  BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$dist km',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF1447E6),
                                      fontWeight:
                                      FontWeight.w600),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}