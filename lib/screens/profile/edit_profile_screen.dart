import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // For File
import 'package:firebase_storage/firebase_storage.dart'; // For Firebase Storage

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _userNameController;
  String? _profileImageUrl;
  File? _pickedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        _userNameController.text = userDoc['username'] ?? '';
        _profileImageUrl = userDoc['profileImageUrl'];
      } else {
        // Create a default user document if it doesn't exist
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'username': user.displayName ?? 'New User',
          'email': user.email ?? '',
          'profileImageUrl': user.photoURL ?? 'https://i.pravatar.cc/150?img=5', // Default placeholder
          'createdAt': FieldValue.serverTimestamp(),
        });
        _userNameController.text = user.displayName ?? 'New User';
        _profileImageUrl = user.photoURL ?? 'https://i.pravatar.cc/150?img=5';
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? newProfileImageUrl = _profileImageUrl;

        if (_pickedImage != null) {
          // Upload image to Firebase Storage
          final storageRef = FirebaseStorage.instance.ref().child('user_images').child('${user.uid}.jpg');
          await storageRef.putFile(_pickedImage!);
          newProfileImageUrl = await storageRef.getDownloadURL();
        }

        // Update user profile in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'username': _userNameController.text.trim(),
          'profileImageUrl': newProfileImageUrl,
        });

        // Update Firebase Auth display name and photo URL
        await user.updateDisplayName(_userNameController.text.trim());
        await user.updatePhotoURL(newProfileImageUrl);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.of(context).pop(); // Go back to profile screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in.')),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF2E7D6E);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _pickedImage != null
                            ? FileImage(_pickedImage!) as ImageProvider
                            : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty
                                ? NetworkImage(_profileImageUrl!)
                                : const AssetImage('assets/placeholder_profile.png')) as ImageProvider, // Placeholder
                        child: _pickedImage == null && (_profileImageUrl == null || _profileImageUrl!.isEmpty)
                            ? Icon(Icons.camera_alt, size: 40, color: Colors.grey.shade600)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _userNameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
