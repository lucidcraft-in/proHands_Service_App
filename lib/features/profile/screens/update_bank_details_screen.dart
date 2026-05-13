import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_button.dart';
import '../../home/providers/consumer_provider.dart';
import '../../../core/models/user_model.dart';

class UpdateBankDetailsScreen extends StatefulWidget {
  const UpdateBankDetailsScreen({super.key});

  @override
  State<UpdateBankDetailsScreen> createState() =>
      _UpdateBankDetailsScreenState();
}

class _UpdateBankDetailsScreenState extends State<UpdateBankDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bankNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _ifscCodeController;
  late TextEditingController _accountHolderNameController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<ConsumerProvider>().currentUser;
    _bankNameController = TextEditingController(
      text: user?.bankDetails?.bankName ?? '',
    );
    _accountNumberController = TextEditingController(
      text: user?.bankDetails?.accountNumber ?? '',
    );
    _ifscCodeController = TextEditingController(
      text: user?.bankDetails?.ifscCode ?? '',
    );
    _accountHolderNameController = TextEditingController(
      text: user?.bankDetails?.accountHolderName ?? '',
    );
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _accountHolderNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);
      try {
        final provider = context.read<ConsumerProvider>();
        final success = await provider.updateProfileBankDetails(
          BankDetails(
            bankName: _bankNameController.text.trim(),
            accountNumber: _accountNumberController.text.trim(),
            ifscCode: _ifscCodeController.text.trim(),
            accountHolderName: _accountHolderNameController.text.trim(),
          ),
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bank details updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                provider.updateProfileError ?? 'Failed to update bank details',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bank Details', style: AppTextStyles.h4),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update your bank account information for payments.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Bank Name',
                hint: 'Enter bank name',
                controller: _bankNameController,
                prefixIcon: const Icon(
                  Iconsax.bank,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
                validator: (v) => v!.isEmpty ? 'Bank name is required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Account Holder Name',
                hint: 'Enter name as per bank records',
                controller: _accountHolderNameController,
                prefixIcon: const Icon(
                  Iconsax.user,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
                validator:
                    (v) =>
                        v!.isEmpty ? 'Account holder name is required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Account Number',
                hint: 'Enter account number',
                controller: _accountNumberController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(
                  Iconsax.card,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
                validator:
                    (v) => v!.isEmpty ? 'Account number is required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'IFSC Code',
                hint: 'Enter IFSC code',
                controller: _ifscCodeController,
                textCapitalization: TextCapitalization.characters,
                prefixIcon: const Icon(
                  Iconsax.code,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
                validator: (v) => v!.isEmpty ? 'IFSC code is required' : null,
              ),
              const SizedBox(height: 40),
              if (_isSaving)
                const Center(child: CircularProgressIndicator())
              else
                GradientButton(
                  text: 'Save Bank Details',
                  onPressed: _handleSave,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
