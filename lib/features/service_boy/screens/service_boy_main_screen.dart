import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/screens/profile_tab_screen.dart';
import 'service_boy_dashboard_screen.dart';
import 'service_boy_tasks_screen.dart';
import 'service_boy_earnings_screen.dart';

class ServiceBoyMainScreen extends StatefulWidget {
  const ServiceBoyMainScreen({super.key});

  @override
  State<ServiceBoyMainScreen> createState() => _ServiceBoyMainScreenState();
}

class _ServiceBoyMainScreenState extends State<ServiceBoyMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ServiceBoyDashboardScreen(),
    const ServiceBoyTasksScreen(),
    const ServiceBoyEarningsScreen(),
    const ProfileTabScreen(),
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
              icon: Icon(Iconsax.grid_1),
              activeIcon: Icon(Iconsax.grid_5),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.task),
              activeIcon: Icon(Iconsax.task_square),
              label: 'Work',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.wallet),
              activeIcon: Icon(Iconsax.wallet_2),
              label: 'Earnings',
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
