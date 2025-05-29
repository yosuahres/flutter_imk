import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fp_imk/db/firestore.dart';

import 'log_activity_screen.dart';

class CarbonFootprintTrackingScreen extends StatefulWidget {
  const CarbonFootprintTrackingScreen({super.key});

  @override
  State<CarbonFootprintTrackingScreen> createState() =>
      _CarbonFootprintTrackingScreenState();
}

class _CarbonFootprintTrackingScreenState
    extends State<CarbonFootprintTrackingScreen> {
  static const Color _appBarColor = Color(0xFF69A56E);
  static const Color _primaryTextColorDarkBg = Colors.white;
  static const Color _scaffoldBgColor = Color(0xFFF0F2F0); // Lighter gray
  static const Color _cardColor = Colors.white;
  static const Color _primaryTextColorLightBg = Colors.black87;
  static const Color _secondaryTextColorLightBg = Colors.black54;
  static const Color _accentColor = Color(0xFF4CAF50); // A slightly brighter green

  User? _currentUser;
  final FirestoreService _firestoreService = FirestoreService();

  double _dailyFootprintKgCO2e = 0.0;
  List<Map<String, dynamic>> _recentActivities = [];

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _fetchFootprintData();
  }

  Future<void> _fetchFootprintData() async {
    if (_currentUser == null) return;

    // Use FirestoreService to get today's logs for this user
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final logsSnapshot = await _firestoreService.getUserFootprintLogs(
      userId: _currentUser!.uid,
      from: startOfDay,
      limit: 5,
    );

    double totalCO2eToday = 0;
    List<Map<String, dynamic>> activities = [];
    for (var doc in logsSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      totalCO2eToday += (data['co2e_kg'] as num? ?? 0.0);
      activities.add({
        'id': doc.id,
        'title': data['activityTitle'] ?? 'Unknown Activity',
        'value': data['co2e_kg'] != null ? "${(data['co2e_kg'] as num).toStringAsFixed(1)} kg CO2e" : "N/A",
        'icon': _getIconForActivity(data['category'] ?? ''),
        'timestamp': data['date'] as Timestamp?,
      });
    }
    if (mounted) {
      setState(() {
        _dailyFootprintKgCO2e = totalCO2eToday;
        _recentActivities = activities;
      });
    }
  }

  IconData _getIconForActivity(String category) {
    switch (category.toLowerCase()) {
      case 'transport':
        return Icons.directions_car;
      case 'energy':
      case 'home energy':
        return Icons.lightbulb_outline;
      case 'food':
        return Icons.restaurant_menu;
      case 'waste':
        return Icons.delete_outline;
      default:
        return Icons.eco;
    }
  }

  void _navigateToLogActivity(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogActivityScreen(category: category),
      ),
    ).then((_) => _fetchFootprintData());
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: _appBarColor,
      statusBarIconBrightness: Brightness.light,
    ));

    String userName = _currentUser?.displayName ?? _currentUser?.email?.split('@')[0] ?? "User";

    return Scaffold(
      backgroundColor: _scaffoldBgColor,
      appBar: _buildAppBar(context, userName),
      body: RefreshIndicator(
        onRefresh: _fetchFootprintData,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildFootprintSummaryCard(),
            const SizedBox(height: 20),
            _buildSectionTitle("Log New Activity"),
            const SizedBox(height: 10),
            _buildActivityLoggingGrid(),
            const SizedBox(height: 20),
            _buildSectionTitle("Recent Activities"),
            const SizedBox(height: 10),
            _buildRecentActivitiesList(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, String userName) {
    return AppBar(
      backgroundColor: _appBarColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: _primaryTextColorDarkBg),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Carbon Footprint Tracking',
        style: TextStyle(color: _primaryTextColorDarkBg, fontWeight: FontWeight.bold),
      ),
      actions: [
        // Center(
        //   child: Padding(
        //     padding: const EdgeInsets.only(right: 8.0),
        //     child: Text(
        //       userName,
        //       style: const TextStyle(color: _primaryTextColorDarkBg, fontSize: 16),
        //     ),
        //   ),
        // ),
        // Padding(
        //   padding: const EdgeInsets.only(right: 16.0),
        //   child: CircleAvatar(
        //     backgroundColor: Colors.white,
        //     child: Icon(Icons.person, color: _appBarColor.withOpacity(0.8), size: 24),
        //     radius: 18,
        //   ),
        // ),
      ],
    );
  }

  Widget _buildFootprintSummaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: _cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Estimated Footprint",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryTextColorLightBg),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _dailyFootprintKgCO2e.toStringAsFixed(1),
                  style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _accentColor),
                ),
                const SizedBox(width: 8),
                Text(
                  "kg CO₂e",
                  style: TextStyle(
                      fontSize: 18,
                      color: _secondaryTextColorLightBg,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "Track your activities to see your impact.",
              style: TextStyle(fontSize: 14, color: _secondaryTextColorLightBg),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _primaryTextColorLightBg.withOpacity(0.8)),
    );
  }

  Widget _buildActivityLoggingGrid() {
    final categories = [
      {"name": "Transport", "icon": Icons.directions_car_filled_outlined},
      {"name": "Home Energy", "icon": Icons.lightbulb_outline_rounded},
      {"name": "Food", "icon": Icons.restaurant_menu_outlined},
      {"name": "Waste", "icon": Icons.delete_sweep_outlined},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: _cardColor,
          child: InkWell(
            onTap: () => _navigateToLogActivity(category["name"] as String),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(category["icon"] as IconData, size: 36, color: _accentColor),
                  const SizedBox(height: 8),
                  Text(
                    category["name"] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _primaryTextColorLightBg),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivitiesList() {
      if (_recentActivities.isEmpty) {
        return Card(
          elevation: 1,
          color: _cardColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "No activities logged recently. Start tracking!",
              textAlign: TextAlign.center,
              style: TextStyle(color: _secondaryTextColorLightBg, fontSize: 15),
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _recentActivities.length,
        itemBuilder: (context, index) {
          final activity = _recentActivities[index];
          final date = activity['timestamp'] != null
              ? (activity['timestamp'] as Timestamp).toDate()
              : null;
          final formattedDate = date != null ? "${date.day}/${date.month}/${date.year}" : "";

          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: _cardColor,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _accentColor.withOpacity(0.1),
                child: Icon(activity['icon'] as IconData, color: _accentColor, size: 24),
              ),
              title: Text(activity['title'] as String, style: TextStyle(fontWeight: FontWeight.w500, color: _primaryTextColorLightBg)),
              subtitle: Text(formattedDate, style: TextStyle(color: _secondaryTextColorLightBg, fontSize: 12)),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    _showEditLogDialog(activity);
                  } else if (value == 'delete') {
                    await _firestoreService.deleteUserFootprintLog(activity['id']);
                    _fetchFootprintData();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ),
          );
        },
      );
    }

     void _showEditLogDialog(Map<String, dynamic> activity) {
    final titleController = TextEditingController(text: activity['title']);
    final valueController = TextEditingController(
      text: (activity['value'] as String).split(' ').first, // get number part
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Log'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Activity Title'),
              ),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(labelText: 'CO₂e (kg)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newTitle = titleController.text.trim();
                final newValue = double.tryParse(valueController.text.trim());
                if (newTitle.isNotEmpty && newValue != null) {
                  await _firestoreService.updateUserFootprintLog(
                    docId: activity['id'],
                    data: {
                      'activityTitle': newTitle,
                      'co2e_kg': newValue,
                    },
                  );
                  Navigator.pop(context);
                  _fetchFootprintData();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

}