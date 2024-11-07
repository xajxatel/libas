import 'package:flutter/material.dart';

import '../main/home_screen.dart';
import '../main/create_screen.dart';
import '../main/outfit_screen.dart';
import '../main/profile_screen.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    const CreateScreen(),
    const OutfitScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tabWidth = screenWidth / 4;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Divider(
                  color: Colors.grey,
                  thickness: 1.0,
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: (tabWidth * _currentIndex) + (tabWidth * 5 / 12),
                top: 17,
                child: Container(
                  width: tabWidth / 6,
                  height: 1.5,
                  color: Colors.black,
                ),
              ),
              BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: _onTabTapped,
                backgroundColor: Colors.transparent,
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                selectedItemColor: Colors.black,
                unselectedItemColor: Colors.grey,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                selectedLabelStyle: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.normal,
                ),
                items: [
                  BottomNavigationBarItem(
                    icon: GestureDetector(
                      onTap: () => _onTabTapped(0),
                      behavior: HitTestBehavior.translucent,
                      child: const SizedBox.shrink(),
                    ),
                    label: 'HOME',
                  ),
                  BottomNavigationBarItem(
                    icon: GestureDetector(
                      onTap: () => _onTabTapped(1),
                      behavior: HitTestBehavior.translucent,
                      child: const SizedBox.shrink(),
                    ),
                    label: 'STUDIO',
                  ),
                  BottomNavigationBarItem(
                    icon: GestureDetector(
                      onTap: () => _onTabTapped(2),
                      behavior: HitTestBehavior.translucent,
                      child: const SizedBox.shrink(),
                    ),
                    label: 'GALLERY',
                  ),
                  BottomNavigationBarItem(
                    icon: GestureDetector(
                      onTap: () => _onTabTapped(3),
                      behavior: HitTestBehavior.translucent,
                      child: const SizedBox.shrink(),
                    ),
                    label: 'PORTFOLIO',
                  ),
                ],
                selectedFontSize: 12.0,
                unselectedFontSize: 12.0,
                enableFeedback: false,
                mouseCursor: SystemMouseCursors.click,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
