import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../booking/screens/booking_tab_screen.dart';
import '../../profile/screens/profile_tab_screen.dart';
import 'home_tab_screen.dart';
import 'explore_screen.dart';
import 'professional_screen.dart';
import '../../cart/screens/cart_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeTabScreen(),
    BookingTabScreen(),
    ExploreScreen(),
    ProfessionalScreen(),
    ProfileTabScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textTertiary,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Iconsax.home),
              activeIcon: Icon(Iconsax.home_15),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.calendar),
              activeIcon: Icon(Iconsax.calendar_15),
              label: 'Booking',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.search_normal),
              activeIcon: Icon(Iconsax.search_normal_1),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.briefcase),
              activeIcon: Icon(Iconsax.briefcase),
              label: 'Professional',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.user),
              activeIcon: Icon(Iconsax.user5),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
