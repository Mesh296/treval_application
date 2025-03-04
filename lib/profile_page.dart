// profile_page.dart
import 'package:flutter/material.dart';
import 'package:treval_application/sign_in_page.dart';
import 'package:treval_application/activities_selection_page.dart';
import '../services/auth.dart';
import '../services/user.dart';
import 'package:intl/intl.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: const Color(0xFF0037CF),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ActivitiesSelectionPage()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchUserData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: const AssetImage(
                                    "assets/images/profile_pic.jpg"),
                                onBackgroundImageError: (_, __) =>
                                    const Icon(Icons.person, size: 50),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _userData?['name'] ?? 'Unnamed User',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '@${_userData?['username'] ?? 'unknown'}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.email_outlined,
                                      color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    _userData?['email'] ?? 'No email',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.black54,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Joined: ${_formatCreatedAt(_userData?['createdAt'])}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'My Activities',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _buildActivitiesList(),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _isLoggingOut ? null : () => _logout(context),
                        icon: _isLoggingOut
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.logout),
                        label: const Text('Log Out'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
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
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'No activities yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
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
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.event, color: Color(0xFF0037CF)),
            title: Text(activity['name'] ?? 'Unnamed Activity'),
            subtitle: Text(
              'Added: ${_formatActivityDate(activity['created_at'])}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
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