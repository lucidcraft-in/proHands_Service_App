import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import '../../home/providers/consumer_provider.dart';
import '../../home/services/consumer_service.dart';
import '../../home/screens/main_screen.dart';
import '../../location/screens/location_fetch_screen.dart';

class NameUpdateScreen extends StatefulWidget {
  const NameUpdateScreen({super.key});

  @override
  State<NameUpdateScreen> createState() => _NameUpdateScreenState();
}

class _NameUpdateScreenState extends State<NameUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    final initialName =
        (user?.name != null && user!.name != 'Guest') ? user.name! : '';
    _nameController = TextEditingController(text: initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _proceedNext() async {
    if (!mounted) return;
    try {
      final consumerService = ConsumerService();
      final fullProfile = await consumerService.getMe();

      if (fullProfile.latitude != null &&
          fullProfile.longitude != null &&
          fullProfile.latitude != 0.0) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
          return;
        }
      }
    } catch (e) {
      // Continue to LocationFetchScreen if profile fetch fails
    }

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LocationFetchScreen(isServiceBoy: false),
        ),
        (route) => false,
      );
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final newName = _nameController.text.trim();

    try {
      final consumerProvider = context.read<ConsumerProvider>();
      final success = await consumerProvider.updateProfileName(name: newName);

      if (success) {
        if (!mounted) return;
        await context.read<AuthProvider>().loadUserFromStorage();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Name updated successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          await _proceedNext();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                consumerProvider.updateProfileError ?? 'Failed to update name',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().currentUser;
    final hasExistingName =
        currentUser?.name != null &&
        currentUser!.name!.isNotEmpty &&
        currentUser.name != 'Guest';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                // Icon Avatar
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(45),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(50),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  "What's your name?",
                  style: AppTextStyles.h2.copyWith(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "Please enter your name so we can personalize your preHands experience.",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 36),
                GradientButton(
                  text: 'Save & Continue',
                  onPressed: _isLoading ? () {} : _handleSave,
                  isLoading: _isLoading,
                  width: double.infinity,
                ),
                if (hasExistingName) ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _isLoading ? null : _proceedNext,
                    child: Text(
                      'Skip for now',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
