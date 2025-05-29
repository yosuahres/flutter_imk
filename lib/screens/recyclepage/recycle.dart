import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:fp_imk/models/recycle_model.dart';

//db
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_imk/db/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

class RecycleScreen extends StatefulWidget {
  const RecycleScreen({Key? key}) : super(key: key);

  @override
  _RecycleState createState() => _RecycleState();
}

class _RecycleState extends State<RecycleScreen> {
  XFile? _mediaFile;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  final List<LoggedRecycleActivity> _loggedActivities = [];
  final List<RecyclingTip> _recyclingTips = [
    RecyclingTip(
      title: "Rinse Containers",
      description: "Clean out food residue from cans, jars, and plastic containers.",
      icon: Icons.cleaning_services_outlined,
    ),
    RecyclingTip(
      title: "Know Your Plastics",
      description: "Check the recycling symbol on plastics. Not all are recyclable everywhere.",
      icon: Icons.sync_alt,
    ),
    RecyclingTip(
      title: "Flatten Cardboard",
      description: "Break down and flatten cardboard boxes to save space.",
      icon: Icons.compress_outlined,
    ),
  ];

  final Color primaryGreen = Colors.green.shade700;
  final Color lightGreenBg = Colors.green.shade50;

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void initState() {
  super.initState();
  _fetchRecycleLogs();
  }


  Future<void> _fetchRecycleLogs() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await _firestoreService.getRecycleLogs(userId: user.uid);
    final activities = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return LoggedRecycleActivity(
        id: doc.id,
        location: data['location'] ?? '',
        description: data['description'],
        mediaFile: null, // You can handle image loading if you store imageUrl
        timestamp: (data['timestamp'] as Timestamp).toDate(),
      );
    }).toList();

    setState(() {
      _loggedActivities
        ..clear()
        ..addAll(activities);
    });
  }


  Future<void> _requestPermissionsAndPickMedia(ImageSource source) async {

    Map<Permission, PermissionStatus> statuses = await [
      source == ImageSource.camera ? Permission.camera : Permission.photos,
    ].request();

    bool granted = true;
    statuses.forEach((permission, status) {
      if (!status.isGranted) granted = false;
    });

    if (granted) {
      try {
        final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
        if (pickedFile != null) {
          setState(() {
            _mediaFile = pickedFile;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking media: $e')),
        );
      }
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Permission denied. Please enable it in app settings.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () {
              openAppSettings();
            },
          ),
        ),
      );
    }
  }

  void _showMediaSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Photo Library'),
                  onTap: () {
                    _requestPermissionsAndPickMedia(ImageSource.gallery);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _requestPermissionsAndPickMedia(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

 void _logRecycleActivity() async {
  if (_locationController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter your location.')),
    );
    return;
  }
  if (_descriptionController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please add a description for what you recycled.')),
    );
    return;
  }

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You must be logged in.')),
    );
    return;
  }

  String? imageUrl;

  await _firestoreService.addRecycleLog(
    userId: user.uid,
    location: _locationController.text,
    description: _descriptionController.text,
    imageUrl: imageUrl,
    timestamp: DateTime.now(),
  );

  setState(() {
    _mediaFile = null;
    _locationController.clear();
    _descriptionController.clear();
  });

  FocusScope.of(context).unfocus();

  await _fetchRecycleLogs();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('Recycling activity logged!'),
      backgroundColor: primaryGreen,
    ),
  );
}

  void _deleteLoggedActivity(String id) async {
    await _firestoreService.deleteRecycleLog(id);
    await _fetchRecycleLogs();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Activity removed.'), backgroundColor: Colors.orangeAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycle'),
        centerTitle: true,
        backgroundColor: primaryGreen,
        // leading: IconButton( 
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              elevation: 2,
              color: lightGreenBg,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.eco, color: primaryGreen, size: 30),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _loggedActivities.isEmpty
                            ? "Log your first recycling activity to see your impact!"
                            : "Awesome! You've logged ${_loggedActivities.length} activit${_loggedActivities.length == 1 ? 'y' : 'ies'}.",
                        style: TextStyle(fontSize: 16, color: primaryGreen),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Recycling Tips',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _recyclingTips.length,
                itemBuilder: (context, index) {
                  final tip = _recyclingTips[index];
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 10.0),
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Icon(tip.icon, color: primaryGreen, size: 20),
                              const SizedBox(width: 8),
                              Expanded(child: Text(tip.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis)),
                            ]),
                            const SizedBox(height: 8),
                            Expanded(child: Text(tip.description, style: TextStyle(fontSize: 13, color: Colors.grey[700]), maxLines: 3, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 25),

            Text(
              'Log New Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            DottedBorder(
              color: primaryGreen.withOpacity(0.7),
              strokeWidth: 1.5,
              dashPattern: const [6, 4],
              borderType: BorderType.RRect,
              radius: const Radius.circular(12),
              padding: EdgeInsets.zero,
              child: Container(
                height: 180, 
                width: double.infinity,
                decoration: BoxDecoration(color: lightGreenBg, borderRadius: BorderRadius.circular(12)),
                child: _mediaFile == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined, size: 50, color: primaryGreen),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                              label: const Text('Add Photo (Optional)'),
                              onPressed: () => _showMediaSourceActionSheet(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen, foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                textStyle: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(File(_mediaFile!.path), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                          ),
                          Positioned(
                            top: 8, right: 8,
                            child: InkWell(
                              onTap: () => setState(() => _mediaFile = null),
                              child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
                                child: const Icon(Icons.close, color: Colors.white, size: 18)),
                            ),
                          )
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 15),
            _buildTextField(_locationController, 'Your Location (e.g., Home, Office Bin)', Icons.location_on_outlined),
            const SizedBox(height: 10),
            _buildTextField(_descriptionController, 'Description (e.g., Plastic bottles, Paper stack)', Icons.description_outlined, maxLines: 2),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Post Recycle Activity'),
                onPressed: _logRecycleActivity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 30),

             if (_loggedActivities.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Logged Activities',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (_loggedActivities.length > 1) TextButton(
                    onPressed: () {
                       setState(() => _loggedActivities.clear());
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('All activities cleared.'), backgroundColor: Colors.orangeAccent),
                       );
                    },
                    child: Text('Clear All', style: TextStyle(color: Colors.red[400])),
                  )
                ],
              ),
              const SizedBox(height: 10),
             ],
            _loggedActivities.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Column(
                        children: [
                          Icon(Icons.list_alt_outlined, size: 50, color: Colors.grey[400]),
                          const SizedBox(height: 10),
                          Text(
                            'No activities logged yet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _loggedActivities.length,
                    itemBuilder: (context, index) {
                      final activity = _loggedActivities[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: lightGreenBg,
                            child: activity.mediaFile != null
                                ? ClipOval(child: Image.file(File(activity.mediaFile!.path), fit: BoxFit.cover, width: 40, height: 40))
                                : Icon(activity.icon, color: primaryGreen),
                          ),
                          title: Text(activity.description ?? 'Recycled Item', style: const TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Location: ${activity.location}'),
                              Text('Logged: ${DateFormat.yMMMd().add_jm().format(activity.timestamp)}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                            onPressed: () => _deleteLoggedActivity(activity.id),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
             const SizedBox(height: 20), 
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, IconData prefixIcon, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: primaryGreen.withOpacity(0.8)),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: primaryGreen, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
      ),
      maxLines: maxLines,
      textInputAction: maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
    );
  }
}