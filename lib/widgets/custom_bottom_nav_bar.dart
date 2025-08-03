import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Color mainColor;
  final Color accentColor;
  final bool isEnglish;
  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.mainColor,
    required this.accentColor,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [mainColor.withOpacity(0.95), accentColor.withOpacity(0.95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        currentIndex: currentIndex,
        onTap: onTap,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: isEnglish ? 'Profile' : 'Profil',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: isEnglish ? 'Home' : 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: isEnglish ? 'Settings' : 'Ayarlar',
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
