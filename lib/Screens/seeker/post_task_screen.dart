import 'package:flutter/material.dart';
import '../../Controllers/task_controller.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

// Screen to allow users to post tasks onto the app/map

class PostTaskScreen extends StatefulWidget {
  const PostTaskScreen({Key? key}) : super(key: key);

  @override
  State<PostTaskScreen> createState() => _PostTaskScreenState();
}

class _PostTaskScreenState extends State<PostTaskScreen> {
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final TaskController _taskController = TaskController();

  String? _selectedCategory;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  bool _isGettingLocation = false;

  double? _selectedLatitude;
  double? _selectedLongitude;

  final List<String> _categories = [
    'Cleaning',
    'Moving',
    'Handyman',
    'Gardening',
    'Pet Care',
    'Tutoring',
    'Other'
  ];

  @override
  void dispose() {
    _taskTitleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission was denied')),
      );
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission is permanently denied'),
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      final hasPermission = await _checkLocationPermission();

      if (!hasPermission) {
        setState(() {
          _isGettingLocation = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String address = 'Current Location';

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        address =
            '${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}'
                .replaceAll(RegExp(r'^,\s*'), '')
                .replaceAll(RegExp(r',\s*,'), ',');
      }

      setState(() {
        _selectedLatitude = position.latitude;
        _selectedLongitude = position.longitude;
        _locationController.text = address;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }

    setState(() {
      _isGettingLocation = false;
    });
  }

  Future<void> _getCoordinatesFromAddress(String address) async {
    if (_selectedLatitude != null && _selectedLongitude != null) {
      return;
    }

    final locations = await locationFromAddress(address);

    if (locations.isNotEmpty) {
      _selectedLatitude = locations.first.latitude;
      _selectedLongitude = locations.first.longitude;
    }
  }

  Future<void> _handlePostTask() async {
    final title = _taskTitleController.text.trim();
    final description = _descriptionController.text.trim();
    final budgetText = _budgetController.text.trim();
    final location = _locationController.text.trim();

    if (title.isEmpty ||
        description.isEmpty ||
        budgetText.isEmpty ||
        location.isEmpty ||
        _selectedCategory == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final deadlineDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    if (deadlineDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deadline must be in the future'),
        ),
      );
      return;
    }

    final budget = double.tryParse(budgetText);
    if (budget == null || budget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid budget')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _getCoordinatesFromAddress(location);

      await _taskController.createTask(
        title: title,
        description: description,
        categoryId: _selectedCategory!,
        location: location,
        price: budget,
        deadline: deadlineDateTime,
        latitude: _selectedLatitude,
        longitude: _selectedLongitude,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task posted successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting task: $e')),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.remove, color: Color(0xFF0A0A0A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Post a Task',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101828),
              ),
            ),
            Text(
              'Describe what you need help with',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Color(0xFF4A5565),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0x1A000000),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildTaskDetailsCard(),
            const SizedBox(height: 24),
            _buildWhenWhereCard(),
            const SizedBox(height: 24),
            _buildPhotosCard(),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputField(
            label: 'Task Title *',
            placeholder: 'e.g., Deep clean 2-bedroom apartment',
            controller: _taskTitleController,
          ),
          const SizedBox(height: 16),
          _buildCategoryDropdown(),
          const SizedBox(height: 16),
          _buildTextArea(
            label: 'Description *',
            placeholder:
            'Provide details about the task, what needs to be done, any special requirements...',
            controller: _descriptionController,
          ),
          const SizedBox(height: 16),
          _buildBudgetField(),
        ],
      ),
    );
  }

  Widget _buildWhenWhereCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'When & Where',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 16),
          _buildLocationField(),
          const SizedBox(height: 16),
          _buildDateField(),
          const SizedBox(height: 16),
          _buildTimeField(),
        ],
      ),
    );
  }

  Widget _buildPhotosCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Photos (Optional)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 16),
          _buildPhotoUpload(),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String placeholder,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F3F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 16, color: Color(0xFF0A0A0A)),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(
                fontSize: 16,
                color: Color(0xFF717182),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F3F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedCategory,
                hint: const Text(
                  'Select a category',
                  style: TextStyle(fontSize: 14, color: Color(0xFF717182)),
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: Color(0x80717182),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea({
    required String label,
    required String placeholder,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F3F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            maxLines: 3,
            style: const TextStyle(fontSize: 16, color: Color(0xFF0A0A0A)),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(
                fontSize: 16,
                color: Color(0xFF717182),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Budget *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F3F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.attach_money,
                  size: 20,
                  color: Color(0xFF99A1AF),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 16, color: Color(0xFF0A0A0A)),
                  decoration: const InputDecoration(
                    hintText: 'Enter your budget',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF717182),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'This is your maximum budget for this task',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF6A7282),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F3F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: Color(0xFF99A1AF),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _locationController,
                  style: const TextStyle(fontSize: 16, color: Color(0xFF0A0A0A)),
                  decoration: const InputDecoration(
                    hintText: 'Enter address or location',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF717182),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  onChanged: (value) {
                    _selectedLatitude = null;
                    _selectedLongitude = null;
                  },
                ),
              ),
              IconButton(
                onPressed: _isGettingLocation ? null : _useCurrentLocation,
                icon: _isGettingLocation
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(
                  Icons.my_location,
                  size: 20,
                  color: Color(0xFF155DFC),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Tap the location icon to use your current location',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF6A7282),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deadline Date',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                    color: Color(0xFF99A1AF),
                  ),
                ),
                Expanded(
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedDate != null
                          ? const Color(0xFF0A0A0A)
                          : const Color(0xFF717182),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deadline Time ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: _selectTime,
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.access_time,
                    size: 20,
                    color: Color(0xFF99A1AF),
                  ),
                ),
                Expanded(
                  child: Text(
                    _selectedTime != null
                        ? _selectedTime!.format(context)
                        : 'Select time',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedTime != null
                          ? const Color(0xFF0A0A0A)
                          : const Color(0xFF717182),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoUpload() {
    return GestureDetector(
      onTap: () {
        Text('Open photo picker');
      },
      child: Container(
        height: 192,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD1D5DC), width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 48,
              color: Color(0xFF99A1AF),
            ),
            SizedBox(height: 8),
            Text(
              'Click to upload photos',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4A5565),
              ),
            ),
            SizedBox(height: 4),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 34),
              child: Text(
                'Add photos to help heroes understand the task better',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6A7282),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0x1A000000)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0A0A0A),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF155DFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: _isLoading ? null : _handlePostTask,
              child: _isLoading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text(
                'Post Task',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}