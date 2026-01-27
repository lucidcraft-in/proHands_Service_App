import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/balance_card.dart';
import 'edit_profile_screen.dart';
import '../../auth/screens/login_screen.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/user_type.dart';
import '../../../core/services/dummy_data_service.dart';

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({super.key});

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'Light';

  // Expansion States
  bool _isFavoritesExpanded = false;
  bool _isLocationsExpanded = false;
  bool _isReviewsExpanded = false;
  bool _isAppDetailsExpanded = false;
  bool _isSettingsExpanded = false;

  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    // For demo purposes, we fetch 'Amjad' if we are in customer context,
    // or 'Amal' if we want to show service boy data.
    // In a real app, this would come from an AuthService/Session.
    _user = DummyDataService.instance.findUserAnyType(
      '+91 9072989925',
    ); // Amjad (Customer)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profile & setting', style: AppTextStyles.h4),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => _handleLogout(context),
            icon: const Icon(Iconsax.logout, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.background,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.primary,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(_user?.name ?? 'Guest User', style: AppTextStyles.h3),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _user?.email ?? 'No email linked',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  BalanceCard(balance: 152.23, onTap: () {}),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // GENERAL Section
            Container(
              color: AppColors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('GENERAL'),

                  if (_user?.userType == UserType.customer) ...[
                    _MenuItem(
                      icon: Iconsax.heart,
                      title: 'Favourite list',
                      isExpanded: _isFavoritesExpanded,
                      onTap:
                          () => setState(
                            () => _isFavoritesExpanded = !_isFavoritesExpanded,
                          ),
                    ),
                    if (_isFavoritesExpanded) _buildFavoritesList(),
                    const Divider(
                      height: 1,
                      indent: 70,
                      color: AppColors.background,
                    ),
                  ],

                  _MenuItem(
                    icon: Iconsax.location,
                    title: 'Manage locations',
                    isExpanded: _isLocationsExpanded,
                    onTap:
                        () => setState(
                          () => _isLocationsExpanded = !_isLocationsExpanded,
                        ),
                  ),
                  if (_isLocationsExpanded) _buildLocationsList(),
                  const Divider(
                    height: 1,
                    indent: 70,
                    color: AppColors.background,
                  ),

                  _MenuItem(
                    icon: Iconsax.message,
                    title: 'My reviews',
                    isExpanded: _isReviewsExpanded,
                    onTap:
                        () => setState(
                          () => _isReviewsExpanded = !_isReviewsExpanded,
                        ),
                  ),
                  if (_isReviewsExpanded) _buildReviewsList(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ABOUT APP Section
            Container(
              color: AppColors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('ABOUT APP'),

                  _MenuItem(
                    icon: Iconsax.info_circle,
                    title: 'App details',
                    subtitle: 'About us, policy & support',
                    isExpanded: _isAppDetailsExpanded,
                    onTap:
                        () => setState(
                          () => _isAppDetailsExpanded = !_isAppDetailsExpanded,
                        ),
                  ),

                  // Flattened App Details Content
                  if (_isAppDetailsExpanded)
                    Padding(
                      padding: const EdgeInsets.only(left: 70, bottom: 8),
                      child: Column(
                        children: [
                          _SubMenuItem(title: 'About Us', onTap: () {}),
                          _SubMenuItem(title: 'Privacy Policy', onTap: () {}),
                        ],
                      ),
                    ),

                  const Divider(
                    height: 1,
                    indent: 70,
                    color: AppColors.background,
                  ),

                  _MenuItem(
                    icon: Iconsax.setting_2,
                    title: 'Settings',
                    isExpanded: _isSettingsExpanded,
                    onTap:
                        () => setState(
                          () => _isSettingsExpanded = !_isSettingsExpanded,
                        ),
                  ),

                  // Settings Content (Merged)
                  if (_isSettingsExpanded)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 12,
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _notificationsEnabled,
                            onChanged: (value) {
                              setState(() => _notificationsEnabled = value);
                            },
                            title: Text(
                              'Push Notifications',
                              style: AppTextStyles.bodyMedium,
                            ),
                            activeColor: AppColors.primary,
                          ),
                          _SettingsMenuRow(
                            title: 'Language',
                            value: _selectedLanguage,
                            onTap: () => _showLanguageDialog(),
                          ),
                          _SettingsMenuRow(
                            title: 'Theme',
                            value: _selectedTheme,
                            onTap: () => _showThemeDialog(),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Logout', style: AppTextStyles.h4),
            content: Text(
              'Are you sure you want to logout?',
              style: AppTextStyles.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Select Language', style: AppTextStyles.h4),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text('English'),
                  value: 'English',
                  groupValue: _selectedLanguage,
                  onChanged: (value) {
                    setState(() => _selectedLanguage = value!);
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Spanish'),
                  value: 'Spanish',
                  groupValue: _selectedLanguage,
                  onChanged: (value) {
                    setState(() => _selectedLanguage = value!);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Select Theme', style: AppTextStyles.h4),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text('Light'),
                  value: 'Light',
                  groupValue: _selectedTheme,
                  onChanged: (value) {
                    setState(() => _selectedTheme = value!);
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Dark'),
                  value: 'Dark',
                  groupValue: _selectedTheme,
                  onChanged: (value) {
                    setState(() => _selectedTheme = value!);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Text(
        title,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildFavoritesList() {
    final favorites = [
      {'name': 'AC Cleaning', 'price': '\$25', 'rating': '4.8'},
      {'name': 'House Painting', 'price': '\$150', 'rating': '4.9'},
      {'name': 'Car Wash', 'price': '\$30', 'rating': '4.7'},
    ];

    return Container(
      height: 140,
      color: AppColors.white,
      padding: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final item = favorites[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item['name']!,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  item['price']!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Color(0xFFFFA928)),
                    const SizedBox(width: 4),
                    Text(
                      item['rating']!,
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationsList() {
    final locations = [
      {'title': 'Home', 'address': '123 Street Name, California, USA'},
      {'title': 'Office', 'address': '456 Business Way, Tech Park, USA'},
    ];

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children:
            locations
                .map(
                  (loc) => Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowLight,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Iconsax.location,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        loc['title']!,
                        style: AppTextStyles.labelSmall,
                      ),
                      subtitle: Text(
                        loc['address']!,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(
                        Icons.edit_location_alt_outlined,
                        size: 18,
                        color: AppColors.textTertiary,
                      ),
                      onTap: () {},
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildReviewsList() {
    final reviews = [
      {
        'user': 'Alex',
        'comment': 'Excellent service, very professional!',
        'rating': '5.0',
      },
      {
        'user': 'Sarah',
        'comment': 'Good experience, arrived on time.',
        'rating': '4.5',
      },
    ];

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children:
            reviews
                .map(
                  (rev) => Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowLight,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: AppColors.primary
                                      .withOpacity(0.1),
                                  child: Text(
                                    rev['user']![0],
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  rev['user']!,
                                  style: AppTextStyles.labelSmall,
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFA928).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 12,
                                    color: Color(0xFFFFA928),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    rev['rating']!,
                                    style: AppTextStyles.caption.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFFFA928),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          rev['comment']!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isExpanded;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.isExpanded = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle:
          subtitle != null
              ? Text(
                subtitle!,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              )
              : null,
      trailing: Icon(
        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
        color: AppColors.textTertiary,
        size: 24,
      ),
      onTap: onTap,
    );
  }
}

class _SubMenuItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SubMenuItem({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsMenuRow extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;

  const _SettingsMenuRow({
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTextStyles.bodyMedium),
            Row(
              children: [
                Text(
                  value,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
