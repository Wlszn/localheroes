import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../settings_screen.dart';

// Main screen for the app Find heroes on the navigation bar at the bottom
class FindHeroesScreen extends StatefulWidget {
  const FindHeroesScreen({super.key});

  @override
  State<FindHeroesScreen> createState() => _FindHeroesScreenState();
}

class _FindHeroesScreenState extends State<FindHeroesScreen> {
  GoogleMapController? _mapController;

  LatLng _currentPosition = const LatLng(45.5017, -73.5673);
  bool _isLoadingLocation = true;

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      setState(() {
        _isLoadingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services')),
      );

      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      setState(() {
        _isLoadingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission was denied')),
      );

      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoadingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission is permanently denied'),
        ),
      );

      return false;
    }

    return true;
  }

  Future<void> _loadCurrentLocation() async {
    final hasPermission = await _checkLocationPermission();

    if (!hasPermission) {
      _addCurrentLocationMarker();
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _isLoadingLocation = false;
    });

    _addCurrentLocationMarker();

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentPosition,
          zoom: 14,
        ),
      ),
    );
  }

  void _addCurrentLocationMarker() {
    setState(() {
      _markers.clear();

      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentPosition,
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'Heroes near you will appear around this area',
          ),
        ),
      );
    });
  }

  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

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
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 18,
                top: 10,
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Find Heroes',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: Color(0xFF6B7280),
                                ),
                                SizedBox(width: 2),
                                Text(
                                  'Current Location',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.notifications_none_outlined,
                          size: 22,
                          color: Color(0xFF111827),
                        ),
                      ),
                      IconButton(
                        onPressed: _goToProfile,
                        icon: const Icon(
                          Icons.person_outline,
                          size: 22,
                          color: Color(0xFF111827),
                        ),
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
                              prefixIcon: Icon(
                                Icons.search,
                                color: Color(0xFF9CA3AF),
                              ),
                              hintText: 'Search by name or skill...',
                              hintStyle: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 16,
                              ),
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
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Icon(
                            Icons.my_location,
                            color: Color(0xFF374151),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition,
                      zoom: 14,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    markers: _markers,
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                  ),
                  if (_isLoadingLocation)
                    Container(
                      color: Colors.white.withOpacity(0.7),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF111827),
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'View as List',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}