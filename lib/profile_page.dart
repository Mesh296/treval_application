import 'package:flutter/material.dart';
import 'package:treval_application/sign_in_page.dart';
import 'package:treval_application/activities_selection_page.dart';
import '../services/auth.dart';
import '../services/user.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthApi _authApi = AuthApi();
  final UserApi _userApi = UserApi();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);
    try {
      final userData = await _userApi.getMe();
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: ${e.toString()}'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _fetchUserData,
            ),
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    setState(() => _isLoggingOut = true);
    try {
      await _authApi.removeToken();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully!')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SignInPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  String _formatCreatedAt(Map<String, dynamic>? createdAt) {
    if (createdAt == null) return 'Unknown';
    try {
      final seconds = createdAt['_seconds'] as int;
      final nanoseconds = createdAt['_nanoseconds'] as int;
      final dateTime = DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + (nanoseconds ~/ 1000000));
      return DateFormat('dd MMMM yyyy').format(dateTime);
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _formatActivityDate(Map<String, dynamic>? createdAt) {
    if (createdAt == null) return 'No date';
    try {
      final seconds = createdAt['_seconds'] as int;
      final nanoseconds = createdAt['_nanoseconds'] as int;
      final dateTime = DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + (nanoseconds ~/ 1000000));
      return DateFormat('dd MMMM yyyy HH:mm').format(dateTime);
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchUserData,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05, // 5% of screen width
                      vertical: screenHeight * 0.02, // 2% of screen height
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Information Section
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Avatar
                            CircleAvatar(
                              radius: screenWidth * 0.12, // 12% of screen width
                              backgroundColor: Colors.grey[200],
                              backgroundImage: const AssetImage(
                                  "assets/images/profile_pic.jpg"),
                              onBackgroundImageError: (_, __) =>
                                  const Icon(Icons.person, size: 40),
                            ),
                            SizedBox(
                                width:
                                    screenWidth * 0.04), // 4% of screen width
                            // Name and Username
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _userData?['name'] ?? 'Unnamed User',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: screenWidth *
                                              0.06, // 6% of screen width
                                        ),
                                  ),
                                  SizedBox(
                                      height: screenHeight *
                                          0.005), // 0.5% of screen height
                                  Row(
                                    children: [
                                      const Icon(Icons.email_outlined,
                                          color: Colors.grey),
                                      SizedBox(width: screenWidth * 0.02),
                                      Text(
                                        '${_userData?['email'] ?? 'unknown'}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: Colors.grey[600],
                                              fontSize: screenWidth *
                                                  0.04, // 4% of screen width
                                            ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: screenHeight * 0.02), // 2% of screen height
                  
                        SizedBox(
                            height: screenHeight * 0.01), // 1% of screen height
                        Text(
                          'Joined: ${_formatCreatedAt(_userData?['createdAt'])}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Colors.grey[600],
                                fontSize:
                                    screenWidth * 0.03, // 3% of screen width
                              ),
                        ),
                        SizedBox(
                            height: screenHeight * 0.03), // 3% of screen height
                        // Edit Favorite Activities Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const ActivitiesSelectionPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0037CF),
                              padding: EdgeInsets.symmetric(
                                vertical:
                                    screenHeight * 0.02, // 2% of screen height
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              "EDIT ACTIVITIES",
                              style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white),
                            ),
                          ),
                        ),

                        SizedBox(
                            height: screenHeight * 0.03), // 3% of screen height
                        // My Activities Section
                        Text(
                          'My Activities',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    screenWidth * 0.05, // 5% of screen width
                              ),
                        ),
                        SizedBox(
                            height: screenHeight * 0.02), // 2% of screen height
                        _buildActivitiesList(),
                        SizedBox(
                            height: screenHeight * 0.03), // 3% of screen height
                        // Log Out Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed:
                                _isLoggingOut ? null : () => _logout(context),
                            icon: _isLoggingOut
                                ? SizedBox(
                                    width: screenWidth *
                                        0.05, // 5% of screen width
                                    height: screenWidth *
                                        0.05, // 5% of screen width
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    Icons.logout,
                                    size: screenWidth * 0.05,
                                    color: Colors.white,
                                  ),
                            label: Text(
                              "LOGOUT",
                              style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(
                                vertical:
                                    screenHeight * 0.02, // 2% of screen height
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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

  Widget _buildActivitiesList() {
    final activities = _userData?['activities'];
    if (activities == null || activities.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(
              MediaQuery.of(context).size.width * 0.04), // 4% of screen width
          child: Center(
            child: Text(
              'No activities yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                    fontSize: MediaQuery.of(context).size.width *
                        0.04, // 4% of screen width
                  ),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return Card(
          margin: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height *
                  0.01), // 1% of screen height
          child: ListTile(
            leading: const Icon(Icons.event, color: Color(0xFF0037CF)),
            title: Text(
              activity['name'] ?? 'Unnamed Activity',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width *
                    0.04, // 4% of screen width
              ),
            ),
            subtitle: Text(
              'Added: ${_formatActivityDate(activity['created_at'])}',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width *
                    0.03, // 3% of screen width
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline,
                  color: Colors.red,
                  size: MediaQuery.of(context).size.width *
                      0.06), // 6% of screen width
              onPressed: () => _removeActivity(activity['activity_id']),
            ),
          ),
        );
      },
    );
  }

  Future<void> _removeActivity(String? activityId) async {
    if (activityId == null) return;
    try {
      await _userApi.removeLikedActivity(activityId);
      await _fetchUserData(); // Refresh the profile data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity removed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove activity: ${e.toString()}')),
      );
    }
  }
}
