import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/company_account_model.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class CompanyAccountDetailsScreen extends StatefulWidget {
  const CompanyAccountDetailsScreen({super.key});

  @override
  State<CompanyAccountDetailsScreen> createState() =>
      _CompanyAccountDetailsScreenState();
}

class _CompanyAccountDetailsScreenState
    extends State<CompanyAccountDetailsScreen> {
  CompanyAccountModel? _account;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAccountDetails();
  }

  Future<void> _fetchAccountDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await StorageService.getAuthToken();
      final url = Uri.parse('${AuthService.baseUrl}/admin/accounts');
      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> accountsList = data['data'] ?? [];
          // Filter for active account
          final activeAccount = accountsList
              .map((json) => CompanyAccountModel.fromJson(json))
              .firstWhere(
                (acc) => acc.isActive,
                orElse: () => throw Exception('No active admin account found'),
              );

          setState(() {
            _account = activeAccount;
            _isLoading = false;
          });
        } else {
          throw Exception(data['message'] ?? 'Failed to load account details');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard(String label, String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showWhatsAppDialog() {
    if (_account == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return WhatsAppPaymentDialog(phoneNumber: _account!.phoneNumber);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Accounts'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Iconsax.danger,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Retry',
                        width: 150,
                        onPressed: _fetchAccountDetails,
                      ),
                    ],
                  ),
                ),
              )
              : _account == null
              ? const Center(child: Text('No active company account available'))
              : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Introduction info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.info_circle5,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Please make your payment to the company account below. Once done, click the WhatsApp button to share the payment screenshot.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color:
                                    isDark
                                        ? Colors.white70
                                        : AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // QR Code Section
                    if (_account!.qrCode.isNotEmpty) ...[
                      Text(
                        'Scan QR to Pay',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? Theme.of(context).colorScheme.surface
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowLight,
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.15),
                            ),
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _account!.qrCode,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.contain,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        width: 200,
                                        height: 200,
                                        color: Colors.grey.shade100,
                                        child: const Icon(
                                          Icons.broken_image,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Scan & Pay using any UPI App',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textTertiary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // UPI Section
                    if (_account!.upiId.isNotEmpty) ...[
                      Text(
                        'UPI ID',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoTile(
                        icon: Iconsax.card_send,
                        title: 'UPI Address',
                        value: _account!.upiId,
                        onCopy:
                            () => _copyToClipboard('UPI ID', _account!.upiId),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Bank Details Section
                    Text(
                      'Bank Account Details',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.15),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowLight,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildBankRow(
                            'Bank Name',
                            _account!.bankDetails.bankName ?? 'N/A',
                          ),
                          const Divider(height: 24),
                          _buildBankRow(
                            'Account Holder',
                            _account!.bankDetails.accountHolderName ?? 'N/A',
                          ),
                          const Divider(height: 24),
                          _buildBankRow(
                            'Account Number',
                            _account!.bankDetails.accountNumber ?? 'N/A',
                            onCopy:
                                () => _copyToClipboard(
                                  'Account Number',
                                  _account!.bankDetails.accountNumber ?? '',
                                ),
                          ),
                          const Divider(height: 24),
                          _buildBankRow(
                            'IFSC Code',
                            _account!.bankDetails.ifscCode ?? 'N/A',
                            onCopy:
                                () => _copyToClipboard(
                                  'IFSC Code',
                                  _account!.bankDetails.ifscCode ?? '',
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Contact Number Section
                    if (_account!.phoneNumber.isNotEmpty) ...[
                      Text(
                        'Support Contact',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoTile(
                        icon: Iconsax.call,
                        title: 'Phone Number',
                        value: _account!.phoneNumber,
                      ),
                      const SizedBox(height: 100), // padding for FAB
                    ],
                  ],
                ),
              ),
      floatingActionButton:
          !_isLoading && _account != null
              ? FloatingActionButton.extended(
                onPressed: _showWhatsAppDialog,
                backgroundColor: const Color(0xFF25D366),
                icon: const Icon(Icons.send, color: Colors.white, size: 24),
                label: const Text(
                  'Submit Proof',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              )
              : null,
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              icon: Icon(Iconsax.copy, color: AppColors.primary, size: 20),
              onPressed: onCopy,
            ),
        ],
      ),
    );
  }

  Widget _buildBankRow(String label, String value, {VoidCallback? onCopy}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onCopy != null)
                GestureDetector(
                  onTap: onCopy,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Iconsax.copy,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class WhatsAppPaymentDialog extends StatefulWidget {
  final String phoneNumber;

  const WhatsAppPaymentDialog({super.key, required this.phoneNumber});

  @override
  State<WhatsAppPaymentDialog> createState() => _WhatsAppPaymentDialogState();
}

class _WhatsAppPaymentDialogState extends State<WhatsAppPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  File? _screenshot;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _screenshot = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error selecting image: $e')));
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitAndLaunchWhatsApp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_screenshot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select payment screenshot proof'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final formattedDate =
        "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}";
    final amount = _amountController.text;

    final message =
        "Hi! I have made a payment of ₹$amount on $formattedDate "
        "for my proHands booking. Please verify the payment.\n\n"
        "Note: Screenshot has been selected and will be attached in chat.";

    final cleanPhone = widget.phoneNumber.replaceAll(RegExp(r'\D'), '');
    final phoneWithCountry =
        cleanPhone.startsWith('91') ? cleanPhone : '91$cleanPhone';

    final whatsappUrl = Uri.parse(
      "whatsapp://send?phone=$phoneWithCountry&text=${Uri.encodeComponent(message)}",
    );
    final fallbackUrl = Uri.parse(
      "https://wa.me/$phoneWithCountry?text=${Uri.encodeComponent(message)}",
    );

    Navigator.pop(context); // Close Dialog

    // Inform user to attach screenshot
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Opening WhatsApp. Please attach your selected screenshot in the chat!',
        ),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.teal,
      ),
    );

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    } else {
      await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Payment Details', style: AppTextStyles.h4),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Date Picker
              Text('Payment Date', style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Iconsax.calendar_1, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Amount Text Field
              CustomTextField(
                label: 'Payment Amount (₹)',
                hint: 'Enter Amount Paid',
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter the amount paid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Screenshot Picker
              Text(
                'Upload Receipt / Screenshot',
                style: AppTextStyles.labelMedium,
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 130,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      _screenshot != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _screenshot!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Iconsax.image5,
                                size: 40,
                                color: AppColors.primary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to Select Screenshot',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton.icon(
                onPressed: _submitAndLaunchWhatsApp,
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text(
                  'Send via WhatsApp',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
