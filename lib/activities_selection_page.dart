// activities_selection_page.dart
import 'package:flutter/material.dart';
import '../services/user.dart';

class ActivitiesSelectionPage extends StatefulWidget {
  const ActivitiesSelectionPage({super.key});

  @override
  _ActivitiesSelectionPageState createState() => _ActivitiesSelectionPageState();
}

class _ActivitiesSelectionPageState extends State<ActivitiesSelectionPage> {
  final UserApi _userApi = UserApi();
  List<Map<String, dynamic>> _activities = [];
  bool _isLoading = true;
  Set<String> _selectedActivities = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
  setState(() => _isLoading = true);
  try {
    final activities = await _userApi.getActivities();
    final userActivities = await _userApi.getMe(); // Lấy thông tin user, bao gồm danh sách activities đã chọn trước đó

    setState(() {
      _activities = activities;
      _selectedActivities = Set<String>.from(userActivities['activities']?.map((a) => a['activity_id'].toString()) ?? []);
      _isLoading = false;
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load activities: ${e.toString()}')),
    );
    setState(() => _isLoading = false);
  }
}


Future<void> _saveSelections() async {
  setState(() => _isSaving = true);

  try {
    await _userApi.addActivities(_selectedActivities.toList()); // Gửi danh sách thay vì từng cái một

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Activities saved successfully!')),
    );
    Navigator.pop(context); // Quay lại trang trước
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save activities: ${e.toString()}')),
    );
  } finally {
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Activities'),
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveSelections,
                ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _activities.length,
              itemBuilder: (context, index) {
                final activity = _activities[index];
                final activityId = activity['activity_id']?.toString() ?? ''; // Safe conversion to String
                return CheckboxListTile(
                  title: Text(activity['name'] ?? 'Unnamed Activity'),
                  value: _selectedActivities.contains(activityId),
                  onChanged: (value) {
                    setState(() {
                      if (value!) {
                        if (activityId.isNotEmpty) {
                          _selectedActivities.add(activityId);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Invalid activity ID, skipping selection.'),
                            ),
                          );
                        }
                      } else {
                        _selectedActivities.remove(activityId);
                      }
                    });
                  },
                );
              },
            ),
    );
  }
}