import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../booking/screens/booking_tab_screen.dart';
import '../../profile/screens/profile_tab_screen.dart';
import 'home_tab_screen.dart';
import 'explore_screen.dart';
import 'professional_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  final int bookingInitialTabIndex;
  const MainScreen({
    super.key,
    this.initialIndex = 0,
    this.bookingInitialTabIndex = 0,
  });

  static MainScreenState? of(BuildContext context) {
    return context.findAncestorStateOfType<MainScreenState>();
  }

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late int currentIndex;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _screens = [
      const HomeTabScreen(),
      BookingTabScreen(initialTabIndex: widget.bookingInitialTabIndex),
      const ExploreScreen(),
      const ProfessionalScreen(),
      const ProfileTabScreen(),
    ];
  }

  void setIndex(int index) {
    setState(() => currentIndex = index);
  }

  Future<bool?> _showExitBottomSheet(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.power_settings_new_rounded,
                  size: 32,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 16),
              Text('Exit App?', style: AppTextStyles.h2.copyWith(fontSize: 20)),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to exit preHands?',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(modalContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.buttonSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(modalContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Exit',
                          style: AppTextStyles.buttonSmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (currentIndex != 0) {
          setState(() => currentIndex = 0);
        } else {
          final shouldExit = await _showExitBottomSheet(context);
          if (shouldExit == true) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        body: IndexedStack(index: currentIndex, children: _screens),
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
            currentIndex: currentIndex,
            onTap: (index) {
              setIndex(index);
            },
            type: BottomNavigationBarType.fixed,
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
                activeIcon: Icon(Iconsax.search_normal),
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
      ),
    );
  }
}
