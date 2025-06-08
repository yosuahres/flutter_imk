import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fp_imk/db/firestore.dart';

// Model for Recycling Guide Items
class RecyclingGuideItem {
  final String header;
  final String body;
  final IconData icon;
  bool isExpanded;

  RecyclingGuideItem({
    required this.header,
    required this.body,
    required this.icon,
    this.isExpanded = false,
  });
}

class RecycleScreen extends StatefulWidget {
  const RecycleScreen({Key? key}) : super(key: key);

  @override
  _RecycleScreenState createState() => _RecycleScreenState();
}

class _RecycleScreenState extends State<RecycleScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  FirestoreService? _firestoreService;

  final _formKey = GlobalKey<FormState>();
  String? _selectedItemType;
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController(text: 'items'); // Default unit
  DateTime _selectedDate = DateTime.now();

  final List<String> _recyclableTypes = [
    'Plastic', 'Paper', 'Glass', 'Metal', 'E-waste', 'Organic', 'Textiles', 'Other'
  ];

  final List<String> _commonUnits = ['items', 'kg', 'grams', 'pieces'];


  // Data for Recycling Guide
  final List<RecyclingGuideItem> _recyclingGuideData = [
    RecyclingGuideItem(
      header: 'Paper & Cardboard',
      icon: Icons.article_outlined,
      body: 'What: Clean newspapers, magazines, office paper, junk mail, phone books, flattened cardboard boxes.\nHow: Keep it dry. Remove any plastic wrapping. For greasy pizza boxes, tear off clean parts if possible, compost or trash greasy parts.\nAvoid: Waxed paper, laminated paper, paper towels, tissues, stickers.',
    ),
    RecyclingGuideItem(
      header: 'Plastics',
      icon: Icons.eco_outlined, // Using eco, could be more specific
      body: 'What: Typically bottles, jugs, and tubs with resin codes #1, #2, #5 (check local rules!).\nHow: Empty and rinse containers. Lids can often be reattached (check locally).\nAvoid: Plastic bags/film (many grocery stores have take-back programs), Styrofoam, plastic cutlery, straws, non-specified hard plastics.',
    ),
    RecyclingGuideItem(
      header: 'Glass',
      icon: Icons.wine_bar_outlined,
      body: 'What: Glass bottles and jars (all colors).\nHow: Empty and rinse. Labels can usually stay on. Lids (metal or plastic) should be removed and recycled separately if possible.\nAvoid: Ceramics, Pyrex, light bulbs, mirrors, window glass.',
    ),
    RecyclingGuideItem(
      header: 'Metals',
      icon: Icons.iron,
      body: 'What: Aluminum cans, steel/tin cans, empty aerosol cans, clean aluminum foil and trays.\nHow: Empty and rinse food cans. For aerosol cans, ensure they are completely empty.\nAvoid: Paint cans (unless empty and dry, check local hazardous waste), electronics, batteries (recycle separately).',
    ),
    RecyclingGuideItem(
      header: 'E-waste (Electronics)',
      icon: Icons.devices_other_outlined,
      body: 'What: Old phones, computers, TVs, cables, chargers, small appliances.\nHow: Look for local e-waste drop-off events or dedicated recycling centers. Erase personal data before recycling.\nAvoid: Putting in regular curbside bins unless specified by local program.',
    ),
  ];


  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    if (_user != null) {
      _firestoreService = FirestoreService(userId: _user!.uid);
    } else {
      print("RecycleScreen: User not logged in!");
    }
  }

  Future<void> _logRecycledItem() async {
    if (_formKey.currentState!.validate()) {
      if (_user == null || _firestoreService == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in.')),
        );
        return;
      }

      final itemData = {
        'itemType': _selectedItemType,
        'itemName': _itemNameController.text.trim(),
        'quantity': double.tryParse(_quantityController.text) ?? 0.0,
        'unit': _unitController.text.trim(),
        'dateRecycled': Timestamp.fromDate(_selectedDate),
        'userId': _user!.uid,
      };

      try {
        await _firestoreService!.addRecycledItem(itemData);

        // Add notification for recycled item
        await _firestoreService!.addNotification({
          'title': 'Item Recycled!',
          'body': 'You recycled ${(itemData['quantity'] as num?)?.toString() ?? 'N/A'} ${itemData['unit'] ?? ''} of ${(itemData['itemName'] as String?)?.isNotEmpty == true ? itemData['itemName'] : itemData['itemType'] ?? 'Unknown Item'}.',
          'type': 'recycle_log',
          'timestamp': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recycled item logged successfully!')),
        );
        _formKey.currentState!.reset();
        _itemNameController.clear();
        _quantityController.clear();
        _unitController.text = 'items'; // Reset to default
        setState(() {
          _selectedItemType = null;
          _selectedDate = DateTime.now();
        });
        Navigator.of(context).pop(); // Close the dialog
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log item: $e')),
        );
      }
    }
  }

  void _showLogRecycledItemDialog() {
     _selectedItemType = null;
    _itemNameController.clear();
    _quantityController.clear();
    _unitController.text = 'items';
    _selectedDate = DateTime.now();


    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.4,
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
                            'Log Recycled Item',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Item Type', border: OutlineInputBorder(), prefixIcon: Icon(Icons.category_outlined)),
                            value: _selectedItemType,
                            hint: const Text('Select Item Type'),
                            items: _recyclableTypes.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setModalState(() {
                                _selectedItemType = newValue;
                              });
                            },
                            validator: (value) => value == null ? 'Please select an item type' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _itemNameController,
                            decoration: const InputDecoration(labelText: 'Item Name/Description (Optional)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.description_outlined)),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _quantityController,
                                  decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder(), prefixIcon: Icon(Icons.format_list_numbered)),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Enter quantity';
                                    if (double.tryParse(value) == null) return 'Invalid number';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()),
                                  value: _unitController.text,
                                  items: _commonUnits.map((String unit) {
                                    return DropdownMenuItem<String>(value: unit, child: Text(unit));
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setModalState(() { _unitController.text = newValue; });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.calendar_today),
                            title: Text("Date: ${MaterialLocalizations.of(context).formatShortDate(_selectedDate)}"),
                            trailing: const Icon(Icons.edit),
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null && picked != _selectedDate) {
                                setModalState(() { _selectedDate = picked; });
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.inventory_2_outlined),
                            label: const Text('Log Item'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF609966),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            onPressed: _logRecycledItem,
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
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF609966);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycle Hub'),
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
                  Text('Please log in to track recycling and view tips.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                ],
              )
            )
          : RefreshIndicator(
            onRefresh: () async {
              // Add any data refresh logic here if needed, e.g., refetching stats or recent items
              // For now, just simulate a delay
              await Future.delayed(const Duration(seconds: 1));
              setState(() {}); // Trigger a rebuild if necessary
            },
            child: ListView( // Changed to ListView for overall scrollability
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                _buildRecyclingImpactCard(themeColor),
                const SizedBox(height: 20),
                _buildSectionHeader('Recycling Guide'),
                _buildRecyclingGuide(),
                const SizedBox(height: 20),
                _buildSectionHeader('Find Local Centers'),
                _buildFindCentersPlaceholder(themeColor),
                const SizedBox(height: 20),
                 _buildSectionHeader('Recently Logged Items'),
                _buildRecentRecyclingActivity(),
                const SizedBox(height: 70), // Space for FAB
              ],
            ),
          ),
      floatingActionButton: _user != null ? FloatingActionButton.extended(
        onPressed: _showLogRecycledItemDialog,
        label: const Text('Log Item'),
        icon: const Icon(Icons.add_circle_outline),
        backgroundColor: themeColor,
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRecyclingImpactCard(Color themeColor) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [themeColor.withOpacity(0.8), themeColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestoreService?.fetchRecyclingStatsThisMonth(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white)));
            }
            int itemsThisMonth = 0;
            double weightDivertedKg = 0.0;
            // final stats = snapshot.data ?? {'itemsThisMonth': 0, 'weightDivertedKg': 0.0};
            if (snapshot.hasData) {
              for (var doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                itemsThisMonth++;
                if ((data['unit'] == 'kg' || data['unit'] == 'grams') && data['quantity'] != null) {
                  weightDivertedKg += (data['quantity'] as num).toDouble();
                } 
              }
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('$itemsThisMonth', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('Items This Month', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                  ],
                ),
                Container(height: 40, width: 1, color: Colors.white30),
                Column(
                  children: [
                    Text('${weightDivertedKg.toStringAsFixed(1)} kg', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('Waste Diverted', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecyclingGuide() {
    return ExpansionPanelList(
      elevation: 1,
      expandedHeaderPadding: const EdgeInsets.symmetric(vertical: 8.0),
      expansionCallback: (int index, bool isCurrentlyExpanded) {
        setState(() {
          // The 'isCurrentlyExpanded' parameter from the callback is the panel's NEW state.
          // So, we set our data model's state to this new state.
          _recyclingGuideData[index].isExpanded = isCurrentlyExpanded;
        });
      },
      children: _recyclingGuideData.map<ExpansionPanel>((RecyclingGuideItem item) {
        return ExpansionPanel(
          canTapOnHeader: true,
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              leading: Icon(item.icon, color: const Color(0xFF609966)),
              title: Text(item.header, style: const TextStyle(fontWeight: FontWeight.w500)),
            );
          },
          body: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
            child: Text(item.body, textAlign: TextAlign.justify, style: TextStyle(height: 1.4)),
          ),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }

  Widget _buildFindCentersPlaceholder(Color themeColor) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          // Placeholder: Navigate to a map screen or show info
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Feature: Find recycling centers (coming soon!)')),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.location_on_outlined, color: themeColor, size: 30),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Find Nearby Recycling Centers',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentRecyclingActivity() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService?.fetchRecentRecycledItems(limit: 3),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final activities = snapshot.data ?? [];
        if (activities.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text('No recycled items logged yet. Tap + to add one!')),
            ),
          );
        }

        return Column( // Use Column instead of ListView.builder directly if inside another ListView
        children: activities.map((activity) {
            final date = (activity['dateRecycled'] as Timestamp?)?.toDate() ?? DateTime.now();
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              elevation: 1.5,
              child: ListTile(
                leading: Icon(_getIconForItemType(activity['itemType'] as String?), color: const Color(0xFF609966)),
                title: Text(
                  '${(activity['itemName'] as String?)?.isNotEmpty == true ? activity['itemName'] : activity['itemType'] ?? 'Unknown Item'}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  '${(activity['quantity'] as num?)?.toString() ?? 'N/A'} ${activity['unit'] ?? ''}\n${MaterialLocalizations.of(context).formatShortDate(date)}',
                ),
                isThreeLine: true,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  IconData _getIconForItemType(String? itemType) {
    switch (itemType) {
      case 'Paper':
      case 'Cardboard':
        return Icons.article_outlined;
      case 'Plastic':
        return Icons.eco_outlined; // Placeholder, could be better
      case 'Glass':
        return Icons.wine_bar_outlined;
      case 'Metal':
        return Icons.iron;
      case 'E-waste':
        return Icons.devices_other_outlined;
      case 'Organic':
        return Icons.compost;
      case 'Textiles':
        return Icons.checkroom;
      default:
        return Icons.recycling;
    }
  }


  @override
  void dispose() {
    _itemNameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }
}
