import 'package:fp_imk/screens/carbonpage/carbon_tracking_page.dart';
import 'package:fp_imk/screens/auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_imk/screens/profile.dart';
import 'package:fp_imk/screens/recyclepage/recycle.dart';
import 'package:fp_imk/screens/weather_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For DocumentSnapshot
import 'package:fp_imk/db/firestore.dart'; // Import FirestoreService

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirestoreService? _firestoreService;

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _firestoreService = FirestoreService(userId: user.uid);
    }
  }

  static const Color _appHeaderColor = Color(0xFF609966);
  static const Color _statusBannerColor = Color(0xFFE9F5DB);
  static const Color _cardColor = Color(0xFFC5E1A5);
  static const Color _bottomNavColor = Color(0xFF386641);
  static const Color _scaffoldBgColor = Color(0xFFF0F2F0);
  static const Color _primaryTextColor = Colors.white;
  static const Color _secondaryTextColor = Color(0xFF333333);
  static const Color _iconColorOnCard = Color(0xFF386641);

  static Future<void> performLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: _appHeaderColor,
      statusBarIconBrightness: Brightness.light,
    ));

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (authSnapshot.hasData) {
          // Now fetch user data from Firestore
          return StreamBuilder<DocumentSnapshot>(
            stream: _firestoreService?.getUserDataStream(),
            builder: (context, userDocSnapshot) {
              if (userDocSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (userDocSnapshot.hasError) {
                return Scaffold(
                  body: Center(child: Text('Error: ${userDocSnapshot.error}')),
                );
              }

              final userData = userDocSnapshot.data?.data() as Map<String, dynamic>?;
              final userName = userData?['username'] ?? authSnapshot.data?.displayName ?? authSnapshot.data?.email?.split('@')[0] ?? "User";
              // If no email and no display name, default to "None"
              final displayUserName = (userName == "User" && authSnapshot.data?.email == null) ? "None" : userName;

              return Scaffold(
                backgroundColor: _scaffoldBgColor,
                body: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      _buildHeader(context, displayUserName),
                      _buildStatusBanner(),
                      Expanded(child: _buildGrid(context)),
                    ],
                  ),
                ),
                bottomNavigationBar: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 8),
                  child: _buildBottomNavigationBar(context),
                ),
              );
            },
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }

  Widget _buildHeader(BuildContext context, String userName) {
    return Container(
      padding: const EdgeInsets.only(top: 16.0 + kToolbarHeight / 3, left: 16.0, right: 16.0, bottom: 16.0),
      color: _appHeaderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.eco_outlined, color: _primaryTextColor, size: 28),
                  SizedBox(width: 8),
                  Text(
                    'Ikling',
                    style: TextStyle(
                        color: _primaryTextColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    userName,
                    style: const TextStyle(color: _primaryTextColor, fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context, MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      );
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: _appHeaderColor.withOpacity(0.8), size: 24,),
                      radius: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Welcome, $userName',
            style: const TextStyle(
                color: _primaryTextColor,
                fontSize: 28,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'What to like to do today?',
            style: TextStyle(color: _primaryTextColor.withOpacity(0.9), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: _statusBannerColor,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green[700], size: 20),
            const SizedBox(width: 8),
            Text(
              'Nothing to worry about. All safe!',
              style: TextStyle(color: Colors.green[800], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) { 
    const IconData newsIcon = Icons.article_outlined;
    const IconData recycleIcon = Icons.recycling_outlined;
    const IconData educationIcon = Icons.science_outlined;
    const IconData footprintIcon = Icons.show_chart_outlined;
    const IconData weatherIcon = Icons.cloud_outlined; 

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
        children: [
          _buildGridItem(context, newsIcon, 'News Feed', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const WeatherPage()));
          }),
          _buildGridItem(context, recycleIcon, 'Recycle', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const RecycleScreen()));
          }),
          _buildGridItem(context, educationIcon, 'Climate Education', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const WeatherPage()));
          }),
          _buildGridItem(context, footprintIcon, 'Carbon Footprint\nTracking', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CarbonTrackingScreen()));
          }),
          _buildGridItem(context, weatherIcon, 'Weather', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const WeatherPage()));
          }),
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, IconData icon, String label, VoidCallback onTapAction) { 
    return Card(
      color: _cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTapAction, 
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: _iconColorOnCard),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _secondaryTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bottomNavColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(Icons.home, 'Home', true, () {

            }),
            _buildBottomNavItem(Icons.notifications_outlined, 'Notification', false, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const WeatherPage()));
            }),
            _buildBottomNavItem(Icons.settings_outlined, 'Settings', false, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const WeatherPage()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? _primaryTextColor : _primaryTextColor.withOpacity(0.7),
                size: 26,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? _primaryTextColor : _primaryTextColor.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
