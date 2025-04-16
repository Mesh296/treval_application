import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treval_application/services/locations.dart';
import 'package:treval_application/services/trips.dart';
import 'package:intl/intl.dart';

class TripDetailPage extends StatefulWidget {
  final String tripId;

  const TripDetailPage({super.key, required this.tripId});

  @override
  _TripDetailPageState createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  final TripApi _tripApi = TripApi();
  final LocationsApi _locationsApi = LocationsApi();
  Map<String, dynamic> _tripDetails = {};
  List<Map<String, dynamic>> _locationDetails = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTripDetails();
  }

  Future<void> _fetchTripDetails() async {
  try {
    final trip = await _tripApi.getTripById(widget.tripId);

    // Gọi API để lấy tên cho từng location
    final locations = trip['locations'] as List<dynamic>? ?? [];
    final List<Map<String, dynamic>> locationDetails = [];

    for (var loc in locations) {
      final locationId = loc['location_id'];
      final locationData = await _locationsApi.getLocationById(locationId);
      print("data location############################");
      print(locationData);
      locationDetails.add({
        'id': locationId,
        'name': locationData['name'], // Giả sử response có 'name'
      });
    }

    if (mounted) {
      setState(() {
        _tripDetails = trip;
        _locationDetails = locationDetails;
        _isLoading = false;
      });
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _errorMessage = 'Failed to load trip details: $e';
        _isLoading = false;
      });
    }
  }
}

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    final seconds = timestamp['_seconds'] as int;
    final date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    return DateFormat('MMM d, yyyy').format(date);
  }

Widget _buildLocationCard(Map<String, dynamic> location) {
  String locationName = location['name'] ?? 'Unknown Location';

  return Card(
    elevation: 4,
    margin: const EdgeInsets.only(bottom: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: Colors.blueAccent,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              locationName,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trip Details',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Trip Name
                          Text(
                            _tripDetails['trip_name'] ?? 'Unknown Trip',
                            style: GoogleFonts.nunito(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Trip Type
                          Row(
                            children: [
                              Icon(
                                _tripDetails['type'] == 'vacation'
                                    ? Icons.beach_access
                                    : _tripDetails['type'] == 'business'
                                        ? Icons.work
                                        : _tripDetails['type'] == 'adventure'
                                            ? Icons.hiking
                                            : Icons.travel_explore,
                                size: 20,
                                color: Colors.blueAccent,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _tripDetails['type']?.toString().capitalize() ?? 'Unknown',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Description
                          Text(
                            'Description',
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _tripDetails['description'] ?? 'No description provided',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Budget
                          Text(
                            'Budget per day',
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${_tripDetails['budget']?.toStringAsFixed(2) ?? '0.00'}',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Date Range
                          Text(
                            'Dates',
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_formatDate(_tripDetails['date_start'])} - ${_formatDate(_tripDetails['date_end'])}',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Locations
                          Text(
                            'Locations',
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _tripDetails['locations']?.isEmpty ?? true
                              ? Text(
                                  'No locations added',
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: (_tripDetails['locations'] as List<dynamic>?)?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    final location = _locationDetails[index];
                                    return _buildLocationCard(location);
                                  },
                                ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}