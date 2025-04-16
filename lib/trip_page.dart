//trip_page
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treval_application/create_trip_page.dart';
import 'package:treval_application/services/trips.dart';
import 'package:treval_application/services/user.dart';
import 'package:treval_application/services/locations.dart';
import 'package:intl/intl.dart';
import 'package:treval_application/trip_detail_page.dart';

class TripPage extends StatefulWidget {
  const TripPage({super.key});

  @override
  _TripPageState createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  final TripApi _tripApi = TripApi();
  final UserApi _userApi = UserApi();
  final LocationsApi _locationsApi = LocationsApi();
  List<dynamic> _ongoingTrips = [];
  List<dynamic> _pastTrips = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTrips();
  }

 Future<void> _fetchTrips() async {
  try {
    // Clear lists to prevent accumulation
    _ongoingTrips = [];
    _pastTrips = [];
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final userData = await _userApi.getMe();
    final trips = userData['trips'] as List<dynamic>? ?? [];
    print('Raw trips from API: ${trips.length} trips');
    trips.forEach((trip) => print('Trip ID: ${trip['id']}, Name: ${trip['trip_name']}'));

    final now = DateTime.now();

    // Deduplicate trips based on their ID
    final uniqueTrips = <String, dynamic>{};
    for (var trip in trips) {
      final tripId = trip['id']?.toString() ?? 'unknown_${trips.indexOf(trip)}';
      if (!uniqueTrips.containsKey(tripId)) {
        uniqueTrips[tripId] = trip;
      } else {
        print('Duplicate trip ID detected: $tripId');
      }
    }
    print('Unique trips after deduplication: ${uniqueTrips.length}');

    // Separate trips into ongoing and past
    final List<dynamic> ongoing = [];
    final List<dynamic> past = [];

    for (var trip in uniqueTrips.values) {
      // Fetch location details
      final List<dynamic> locations = trip['locations'] ?? [];
      final List<Map<String, dynamic>> fullLocations = [];

      for (var loc in locations) {
        try {
          final locationId = loc['location_id'];
          if (locationId != null) {
            final locationDetail = await _locationsApi.getLocationById(locationId);
            print('Fetched location for ID $locationId: $locationDetail');
            fullLocations.add({
              'id': locationId,
              'name': locationDetail['name'], // Ensure the response has 'name'
            });
          }
        } catch (e) {
          print('Failed to load location $loc: $e');
          fullLocations.add({
            'id': loc['location_id'],
            'name': 'Unknown Location',
          });
        }
      }

      // Assign the updated locations back to the trip
      trip['locations'] = fullLocations;
      print('Trip: ${trip['trip_name']}, Locations: $fullLocations');

      // Classify trip as ongoing or past
      try {
        final dateEndSeconds = trip['date_end']?['_seconds'] as int?;
        if (dateEndSeconds == null) {
          past.add(trip);
          continue;
        }
        final dateEnd = DateTime.fromMillisecondsSinceEpoch(dateEndSeconds * 1000);
        if (dateEnd.isAfter(now)) {
          ongoing.add(trip);
        } else {
          past.add(trip);
        }
      } catch (e) {
        print('Error processing date for trip ID: ${trip['id']}: $e');
        past.add(trip);
      }
    }

    if (mounted) {
      setState(() {
        _ongoingTrips = ongoing;
        _pastTrips = past;
        print('Ongoing trips count: ${_ongoingTrips.length}');
        _ongoingTrips.forEach((trip) => print('Ongoing Trip ID: ${trip['id']}, Name: ${trip['trip_name']}'));
        _isLoading = false;
      });
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _errorMessage = 'Failed to load trips: $e';
        _isLoading = false;
      });
    }
  }
}
  String _getImagePath(String locationName) {
    final Map<String, String> locationImageMap = {
      "Tokyo, Japan": "tokyo.jpg",
      "Florence, Italy": "florence.jpg",
      "Banff National Park, Canada": "banff_national_park.jpg",
      "Paris, France": "paris.jpg",
      "Lake Tahoe, USA": "lake_tahoe.jpg",
      "Cape Town, South Africa": "cape_town.jpg",
      "New York City, NY, USA": "newyork.jpg",
      "Great Barrier Reef, Australia": "great_barrier_reef.jpg",
      "Yellowstone National Park, USA": "yellowstone.jpg",
      "Scottish Highlands, Scotland": "scottish.jpg",
      "Saint Petersburg, Russia": "petersburg.jpg",
      "Murmansk, Russia": "murmansk.jpg",
    };

    String? imageFileName = locationImageMap[locationName];
    return 'assets/images/${imageFileName ?? "mount_fuji.jpg"}';
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    final seconds = timestamp['_seconds'] as int;
    final date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    return DateFormat('MMM d, yyyy').format(date);
  }

  Widget _buildTripCard(dynamic trip, bool isOngoing) {
  // Extract the first location name for display and image mapping
  String locationName = trip['locations']?.isNotEmpty == true
      ? trip['locations'][0]['name'] ?? 'Unknown'
      : 'Unknown';
  String dateRange = "${_formatDate(trip['date_start'])} - ${_formatDate(trip['date_end'])}";
  String imagePath = _getImagePath(locationName); // Use the actual location name for the image
  String tripType = trip['type']?.toString().toLowerCase() ?? 'unknown';

  // Map trip types to icons
  IconData getTripTypeIcon(String type) {
    switch (type) {
      case 'vacation':
        return Icons.beach_access;
      case 'business':
        return Icons.work;
      case 'adventure':
        return Icons.hiking;
      default:
        return Icons.travel_explore;
    }
  }

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TripDetailPage(tripId: trip['id']),
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                children: [
                  // Trip Image
                  Image.asset(
                    imagePath,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Center(child: Text('Image not found')),
                      );
                    },
                  ),
                  // Gradient Overlay
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Trip Details
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                trip['trip_name'] ?? 'Unknown Trip',
                                style: GoogleFonts.nunito(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isOngoing ? Colors.green.withOpacity(0.8) : Colors.red.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isOngoing ? 'Ongoing' : 'Past',
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                locationName,
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dateRange,
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              getTripTypeIcon(tripType),
                              size: 16,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              CapitalizeExtension(tripType).capitalize(),
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Slight tilt effect
          Positioned.fill(
            child: Transform(
              transform: Matrix4.rotationZ(isOngoing ? 0.02 : -0.02),
              alignment: Alignment.center,
              child: Container(),
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ongoing Trips",
                  style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87),
                ),
                const SizedBox(height: 10),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? Center(child: Text(_errorMessage!))
                        : _ongoingTrips.isEmpty
                            ? const Center(child: Text("No ongoing trips"))
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _ongoingTrips.length,
                                itemBuilder: (context, index) {
                                  return _buildTripCard(
                                      _ongoingTrips[index], true);
                                },
                              ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CreateTripPage()),
                      ).then((_) => _fetchTrips());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0037CF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 5,
                    ),
                    child: Text(
                      "CREATE NEW TRIP",
                      style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Past Trips",
                  style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? Center(child: Text(_errorMessage!))
                        : _pastTrips.isEmpty
                            ? const Center(child: Text("No past trips"))
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _pastTrips.length,
                                itemBuilder: (context, index) {
                                  return _buildTripCard(
                                      _pastTrips[index], false);
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
extension CapitalizeExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
