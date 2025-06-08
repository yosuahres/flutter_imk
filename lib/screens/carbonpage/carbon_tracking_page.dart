import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fp_imk/db/firestore.dart'; // Use your real FirestoreService

class CarbonTrackingScreen extends StatefulWidget {
  const CarbonTrackingScreen({Key? key}) : super(key: key);

  @override
  _CarbonTrackingScreenState createState() => _CarbonTrackingScreenState();
}

class _CarbonTrackingScreenState extends State<CarbonTrackingScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  FirestoreService? _firestoreService;

  // Form state
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  String? _selectedActivity;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  final Map<String, List<String>> _activitiesByCategory = {
    'Transport': ['Car (Gasoline)', 'Car (Diesel)', 'Motorbike', 'Bus', 'Train', 'Flight (Short Haul)', 'Flight (Long Haul)'],
    'Household Energy': ['Electricity', 'Natural Gas', 'Heating Oil'],
    'Food': ['Beef', 'Lamb', 'Pork', 'Chicken', 'Fish', 'Dairy', 'Vegetables', 'Fruits'],
    'Goods & Services': ['Clothing', 'Electronics', 'Services'],
  };

  final Map<String, String> _activityUnits = {
    'Car (Gasoline)': 'km',
    'Car (Diesel)': 'km',
    'Motorbike': 'km',
    'Bus': 'km',
    'Train': 'km',
    'Flight (Short Haul)': 'km',
    'Flight (Long Haul)': 'km',
    'Electricity': 'kWh',
    'Natural Gas': 'm³ or kWh',
    'Heating Oil': 'litres',
    'Beef': 'kg',
    'Lamb': 'kg',
    'Pork': 'kg',
    'Chicken': 'kg',
    'Fish': 'kg',
    'Dairy': 'kg or L',
    'Vegetables': 'kg',
    'Fruits': 'kg',
    'Clothing': 'items or spend',
    'Electronics': 'items or spend',
    'Services': 'spend'
  };

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    if (_user != null) {
      _firestoreService = FirestoreService(userId: _user!.uid);
    } else {
      print("User not logged in!");
    }
  }

  Future<void> _logCarbonEntry() async {
    if (_formKey.currentState!.validate()) {
      if (_user == null || _firestoreService == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in.')),
        );
        return;
      }
      if (_selectedCategory == null || _selectedActivity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select category and activity.')),
        );
        return;
      }

      double dummyCo2 = (double.tryParse(_quantityController.text) ?? 1.0) * 2.5; // Replace with real calculation if available

      final entryData = {
        'category': _selectedCategory,
        'activity': _selectedActivity,
        'quantity': double.tryParse(_quantityController.text) ?? 0.0,
        'unit': _activityUnits[_selectedActivity!] ?? '',
        'notes': _notesController.text,
        'co2': dummyCo2,
        'date': Timestamp.fromDate(_selectedDate),
        'userId': _user!.uid,
      };

      try {
        await _firestoreService!.addCarbonEntry(entryData);
        
        // Add notification for carbon entry
        await _firestoreService!.addNotification({
          'title': 'Carbon Footprint Logged!',
          'body': 'You logged ${dummyCo2.toStringAsFixed(1)} kg CO₂e for ${_selectedActivity ?? _selectedCategory}.',
          'type': 'carbon_log',
          'timestamp': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Carbon entry logged successfully!')),
        );
        _formKey.currentState!.reset();
        _quantityController.clear();
        _notesController.clear();
        setState(() {
          _selectedCategory = null;
          _selectedActivity = null;
          _selectedDate = DateTime.now();
        });
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log entry: $e')),
        );
      }
    }
  }

  void _showAddEntryDialog() {
    _selectedCategory = null;
    _selectedActivity = null;
    _quantityController.clear();
    _notesController.clear();
    _selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder: (_, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        controller: scrollController,
                        children: <Widget>[
                          Text(
                            'Log New Carbon Activity',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category)),
                            value: _selectedCategory,
                            hint: const Text('Select Category'),
                            items: _activitiesByCategory.keys.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setModalState(() {
                                _selectedCategory = newValue;
                                _selectedActivity = null;
                              });
                            },
                            validator: (value) => value == null ? 'Please select a category' : null,
                          ),
                          const SizedBox(height: 16),
                          if (_selectedCategory != null)
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                  labelText: 'Activity',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.local_activity)),
                              value: _selectedActivity,
                              hint: const Text('Select Activity'),
                              items: (_activitiesByCategory[_selectedCategory!] ?? []).map((String activity) {
                                return DropdownMenuItem<String>(
                                  value: activity,
                                  child: Text(activity),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setModalState(() {
                                  _selectedActivity = newValue;
                                });
                              },
                              validator: (value) => value == null ? 'Please select an activity' : null,
                            ),
                          const SizedBox(height: 16),
                          if (_selectedActivity != null)
                            TextFormField(
                              controller: _quantityController,
                              decoration: InputDecoration(
                                labelText: 'Quantity / Amount',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.format_list_numbered),
                                suffixText: _activityUnits[_selectedActivity!] ?? '',
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a quantity';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          const SizedBox(height: 16),
                          ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: Text("Date: ${MaterialLocalizations.of(context).formatShortDate(_selectedDate)}"),
                            trailing: const Icon(Icons.edit),
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null && picked != _selectedDate) {
                                setModalState(() {
                                  _selectedDate = picked;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _notesController,
                            decoration: const InputDecoration(
                              labelText: 'Notes (Optional)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.note_alt_outlined),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.save_alt_outlined),
                            label: const Text('Log Entry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF609966),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            onPressed: _logCarbonEntry,
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF609966);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carbon Footprint Tracker'),
        backgroundColor: themeColor,
        elevation: 0,
      ),
      body: _user == null && _firestoreService == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 50, color: Colors.redAccent),
                  SizedBox(height: 10),
                  Text('Please log in to track your carbon footprint.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                ],
              )
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildTotalFootprintCard(themeColor),
                  const SizedBox(height: 20),
                  _buildPlaceholderChartCard(themeColor),
                  const SizedBox(height: 20),
                  Text(
                    'Recent Activities',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildRecentActivitiesList(),
                ],
              ),
            ),
      floatingActionButton: _user != null ? FloatingActionButton.extended(
        onPressed: _showAddEntryDialog,
        label: const Text('Log Activity'),
        icon: const Icon(Icons.add_circle_outline),
        backgroundColor: themeColor,
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTotalFootprintCard(Color themeColor) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [themeColor.withOpacity(0.8), themeColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Estimated Monthly Footprint',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            StreamBuilder<double>(
              stream: _firestoreService?.getTotalCarbonFootprint() ?? Stream.value(0.0),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 40,
                    width: 40,
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                  );
                }
                if (snapshot.hasError) {
                  return Text('Error', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold));
                }
                final totalFootprint = snapshot.data ?? 0.0;
                return Text(
                  '${totalFootprint.toStringAsFixed(1)} kg CO₂e',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              'Keep logging to improve accuracy!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildPlaceholderChartCard(Color themeColor) {
  return Card(
    elevation: 2.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Footprint Breakdown',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestoreService?.getRecentCarbonEntries(limit: 100) ?? Stream.value([]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading chart'));
                }
                final entries = snapshot.data ?? [];
                if (entries.isEmpty) {
                  return Center(child: Text('No data yet'));
                }

                // Aggregate CO2 by category
                final Map<String, double> categoryTotals = {};
                for (var entry in entries) {
                  final category = entry['category'] ?? 'Other';
                  final co2 = (entry['co2'] as num?)?.toDouble() ?? 0.0;
                  categoryTotals[category] = (categoryTotals[category] ?? 0) + co2;
                }

                final categories = categoryTotals.keys.toList();
                final values = categoryTotals.values.toList();

                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (values.isNotEmpty) ? (values.reduce((a, b) => a > b ? a : b) * 1.2) : 10,
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= categories.length) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                categories[idx].split(' ').first,
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          },
                          reservedSize: 40,
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(categories.length, (i) {
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: values[i],
                            color: themeColor,
                            width: 22,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      );
                    }),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Shows your CO₂e by category.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildRecentActivitiesList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService?.getRecentCarbonEntries(limit: 5) ?? Stream.value([]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error fetching activities: ${snapshot.error}'));
        }
        final activities = snapshot.data ?? [];
        if (activities.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text('No activities logged yet. Tap + to add one!')),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            final date = (activity['date'] as Timestamp?)?.toDate() ?? DateTime.now();
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              elevation: 1.5,
              child: ListTile(
                leading: Icon(_getIconForCategory(activity['category'] as String?), color: const Color(0xFF609966)),
                title: Text(
                  '${activity['activity'] ?? 'Unknown Activity'}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  '${activity['notes'] ?? activity['category']}\n${MaterialLocalizations.of(context).formatShortDate(date)}',
                ),
                trailing: Text(
                  '${(activity['co2'] as num?)?.toStringAsFixed(1) ?? '0.0'} kg CO₂e',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF609966)),
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  IconData _getIconForCategory(String? category) {
    switch (category) {
      case 'Transport':
        return Icons.directions_car;
      case 'Household Energy':
        return Icons.lightbulb_outline;
      case 'Food':
        return Icons.restaurant;
      case 'Goods & Services':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.eco;
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
