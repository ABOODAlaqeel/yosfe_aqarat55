import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dashboard/dashboard_screen.dart';
import '../screens/buildings/buildings_screen.dart';
import '../screens/tenants/tenants_screen.dart';
import '../core/constants/colors.dart';
import '../core/constants/styles.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const BuildingsScreen(),
    const TenantsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: _buildNavIcon(CupertinoIcons.square_grid_2x2, 0),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(CupertinoIcons.building_2_fill, 1),
                label: 'العمارات',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(CupertinoIcons.person_3_fill, 2),
                label: 'المستأجرين',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    final isSelected = _currentIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textLight,
        size: isSelected ? 26 : 22,
      ),
    );
  }
}
