import 'package:flutter/material.dart';
import 'package:fp_imk/screens/home.dart';
import 'package:fp_imk/screens/notification/notification_screen.dart';
import 'package:fp_imk/screens/profile/app_settings_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  static const Color _bottomNavColor = Color(0xFF386641);
  static const Color _primaryTextColor = Colors.white;

  Widget _buildBottomNavItem(IconData icon, String label, bool isSelected) {
    return Expanded(
      child: InkWell(
        onTap: () => onItemTapped(
          label == 'Home' ? 0 : (label == 'Notification' ? 1 : 2)
        ),
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

  @override
  Widget build(BuildContext context) {
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
            _buildBottomNavItem(Icons.home, 'Home', selectedIndex == 0),
            _buildBottomNavItem(Icons.notifications_outlined, 'Notification', selectedIndex == 1),
            _buildBottomNavItem(Icons.settings_outlined, 'Settings', selectedIndex == 2),
          ],
        ),
      ),
    );
  }
}
