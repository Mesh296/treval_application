import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treval_application/create_trip_page.dart';
import 'package:treval_application/services/trips.dart';
import 'package:treval_application/services/user.dart';
import 'package:treval_application/services/locations.dart';
import 'package:intl/intl.dart';
import 'package:treval_application/trip_detail_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
  bool _isDeleting = false;
  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _fetchTrips();
  }

  Future<void> _initializeNotifications() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('ic_notification');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin!.initialize(initializationSettings);

    // Request permissions for Android 13+
    if (Theme.of(context).platform == TargetPlatform.android) {
      await _flutterLocalNotificationsPlugin!
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> _showNotification(String tripName, String startDate, String locationName) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'trip_channel',
      'Trip Reminders',
      channelDescription: 'Notifications for upcoming trip start dates',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin!.show(
      tripName.hashCode, // Unique ID based on trip name
      'Upcoming Trip: $tripName',
      'Your trip to $locationName starts on $startDate!',
      platformDetails,
      payload: tripName,
    );
  }

  Future<void> _fetchTrips() async {
    try {
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
      final notificationThreshold = now.add(Duration(days: 3)); // Notify for trips starting within 3 days

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

      final List<dynamic> ongoing = [];
      final List<dynamic> past = [];

      for (var trip in uniqueTrips.values) {
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
                'name': locationDetail['name'],
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

        trip['locations'] = fullLocations;
        print('Trip: ${trip['trip_name']}, Locations: $fullLocations');

        // Check for upcoming start date
        try {
          final dateStartSeconds = trip['date_start']?['_seconds'] as int?;
          if (dateStartSeconds != null) {
            final dateStart = DateTime.fromMillisecondsSinceEpoch(dateStartSeconds * 1000);
            if (dateStart.isAfter(now) && dateStart.isBefore(notificationThreshold)) {
              final tripName = trip['trip_name'] ?? 'Unknown Trip';
              final startDate = _formatDate(trip['date_start']);
              final locationName = fullLocations.isNotEmpty ? fullLocations[0]['name'] : 'Unknown';
              await _showNotification(tripName, startDate, locationName);
            }
          }
        } catch (e) {
          print('Error processing start date for trip ID: ${trip['id']}: $e');
        }

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

  Future<void> _deleteTrip(String tripId) async {
    setState(() {
      _isDeleting = true;
    });

    try {
      await _tripApi.deleteTrip(tripId);
      await _fetchTrips();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trip deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete trip: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  void _showDeleteConfirmation(String tripId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Trip'),
        content: Text('Are you sure you want to delete this trip? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTrip(tripId);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
    String locationName = trip['locations']?.isNotEmpty == true
        ? trip['locations'][0]['name'] ?? 'Unknown'
        : 'Unknown';
    String dateRange = "${_formatDate(trip['date_start'])} - ${_formatDate(trip['date_end'])}";
    String imagePath = _getImagePath(locationName);
    String tripType = trip['type']?.toString().toLowerCase() ?? 'unknown';

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
        margin: const EdgeInsets.only(bottom: 20),
        child: Stack(
          children: [
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  children: [
                    Image.asset(
                      imagePath,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 220,
                          color: Colors.grey[300],
                          child: const Center(child: Text('Image not found')),
                        );
                      },
                    ),
                    Container(
                      height: 220,
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
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: _isDeleting ? null : () => _showDeleteConfirmation(trip['id']),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.5),
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: _isDeleting
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  Icons.delete,
                                  color: Colors.red[400],
                                  size: 20,
                                ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
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
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                dateRange,
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                getTripTypeIcon(tripType),
                                size: 16,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 6),
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

extension CapitalizeExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}