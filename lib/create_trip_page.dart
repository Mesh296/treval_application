import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:treval_application/services/trips.dart';
import 'package:treval_application/services/user.dart';

class CreateTripPage extends StatefulWidget {
  const CreateTripPage({super.key});

  @override
  _CreateTripPageState createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  final _formKey = GlobalKey<FormState>();
  final TripApi _tripApi = TripApi();
  final UserApi _userApi = UserApi();
  List<dynamic> _locations = [];
  String? _selectedLocationId;
  String? _selectedLocationName;
  DateTime? _startDate;
  DateTime? _endDate;
  double? _budget;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tripNameController = TextEditingController();
  String _tripType = 'vacation';
  bool _isSubmitting = false;
  bool _isLoadingLocations = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  Future<void> _fetchLocations() async {
    try {
      final response = await _userApi.getRecommendedLocationsAndOffers();
      if (mounted) {
        setState(() {
          _locations = response['locations'] ?? [];
          _isLoadingLocations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load locations: $e';
          _isLoadingLocations = false;
        });
      }
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _submitTrip() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLocationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location')),
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }

    if (_budget == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a budget')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // Create the trip
      final tripId = await _tripApi.createTrip(
        tripName: _tripNameController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _tripType,
        budget: _budget!,
        startDate: DateFormat('yyyy-MM-dd').format(_startDate!),
        endDate: DateFormat('yyyy-MM-dd').format(_endDate!),
      );

      // Add the selected location to the trip
      await _tripApi.addLocationToTrip(
        tripId: tripId,
        locationId: _selectedLocationId!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip created successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create trip: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Create New Trip',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _tripNameController,
                    decoration: InputDecoration(
                      hintText: 'Trip Name',
                      hintStyle: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey[400]!,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF0037CF),
                          width: 2.0,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a trip name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: 'Trip Description',
                      hintStyle: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey[400]!,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF0037CF),
                          width: 2.0,
                        ),
                      ),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      hintText: 'Trip Type',
                      hintStyle: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey[400]!,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF0037CF),
                          width: 2.0,
                        ),
                      ),
                    ),
                    value: _tripType,
                    items: const [
                      DropdownMenuItem(value: 'vacation', child: Text('Vacation')),
                      DropdownMenuItem(value: 'business', child: Text('Business')),
                      DropdownMenuItem(value: 'adventure', child: Text('Adventure')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _tripType = value!;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select a trip type' : null,
                  ),
                  const SizedBox(height: 20),
                  _isLoadingLocations
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                          ? Center(child: Text(_errorMessage!))
                          : DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                hintText: 'Choose your location',
                                hintStyle: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[600],
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey[400]!,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF0037CF),
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              value: _selectedLocationId,
                              items: _locations.map((location) {
                                return DropdownMenuItem<String>(
                                  value: location['location_id'],
                                  child: Text(location['name'] ?? ''),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedLocationId = value;
                                  _selectedLocationName = _locations
                                      .firstWhere((loc) =>
                                          loc['location_id'] == value)['name'];
                                });
                              },
                              validator: (value) =>
                                  value == null ? 'Please select a location' : null,
                            ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectStartDate(context),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              hintText: _startDate == null
                                  ? 'Choose start date'
                                  : DateFormat('yyyy-MM-dd').format(_startDate!),
                              hintStyle: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600],
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey[400]!,
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF0037CF),
                                  width: 2.0,
                                ),
                              ),
                            ),
                            child: Text(
                              _startDate == null
                                  ? 'Choose start date'
                                  : DateFormat('yyyy-MM-dd').format(_startDate!),
                              style: TextStyle(
                                color: _startDate == null
                                    ? Colors.grey[600]
                                    : Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectEndDate(context),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              hintText: _endDate == null
                                  ? 'Choose end date'
                                  : DateFormat('yyyy-MM-dd').format(_endDate!),
                              hintStyle: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600],
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey[400]!,
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF0037CF),
                                  width: 2.0,
                                ),
                              ),
                            ),
                            child: Text(
                              _endDate == null
                                  ? 'Choose end date'
                                  : DateFormat('yyyy-MM-dd').format(_endDate!),
                              style: TextStyle(
                                color: _endDate == null
                                    ? Colors.grey[600]
                                    : Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Budget per day per person',
                      hintStyle: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey[400]!,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF0037CF),
                          width: 2.0,
                        ),
                      ),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      setState(() {
                        _budget = double.tryParse(value) ?? 0.0;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a budget';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: _isSubmitting
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _submitTrip,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0037CF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: Text(
                              "START MY TRIP",
                              style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _tripNameController.dispose();
    super.dispose();
  }
}