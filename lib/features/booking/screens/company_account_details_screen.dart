import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/company_account_model.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class CompanyAccountDetailsScreen extends StatefulWidget {
  final String bookingId;
  final String displayBookingId;
  final String customerName;

  const CompanyAccountDetailsScreen({
    super.key,
    required this.bookingId,
    required this.displayBookingId,
    required this.customerName,
  });

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
        return WhatsAppPaymentDialog(
          phoneNumber: _account!.phoneNumber,
          bookingId: widget.bookingId,
          displayBookingId: widget.displayBookingId,
          customerName: widget.customerName,
        );
      },
    );
  }

  Future<void> _downloadQR() async {
    if (_account == null || _account!.qrCode.isEmpty) return;

    // Show custom visual loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Downloading QR Code...',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );

    try {
      // 1. Download bytes from URL
      final response = await http.get(Uri.parse(_account!.qrCode));
      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      // 2. Save bytes to temporary file path
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/prohands_qr_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // 3. Save file to gallery
      await Gal.putImage(filePath);

      // Dismiss loader
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR Code successfully saved to your Gallery!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.teal,
          ),
        );
      }
    } catch (e) {
      // Dismiss loader
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save to Gallery: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: _downloadQR,
                                icon: Icon(
                                  Iconsax.document_download,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                                label: Text(
                                  'Download QR Code',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
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
              ? FloatingActionButton(
                onPressed: _showWhatsAppDialog,
                backgroundColor: const Color(0xFF25D366),
                child: SvgPicture.string(
                  _whatsappSvg,
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                // label: const Text(
                //   'Submit Proof',
                //   style: TextStyle(
                //     color: Colors.white,
                //     fontWeight: FontWeight.bold,
                //     fontSize: 16,
                //   ),
                // ),
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
  final String bookingId;
  final String displayBookingId;
  final String customerName;

  const WhatsAppPaymentDialog({
    super.key,
    required this.phoneNumber,
    required this.bookingId,
    required this.displayBookingId,
    required this.customerName,
  });

  @override
  State<WhatsAppPaymentDialog> createState() => _WhatsAppPaymentDialogState();
}

class _WhatsAppPaymentDialogState extends State<WhatsAppPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  File? _screenshot;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

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

    setState(() {
      _isSubmitting = true;
    });

    try {
      final token = await StorageService.getAuthToken();
      final url = Uri.parse('${AuthService.baseUrl}/payment-screenshots');

      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['phoneNumber'] = widget.phoneNumber;
      request.fields['amount'] = _amountController.text.trim();
      request.fields['bookingId'] = widget.bookingId;
      request.fields['paymentDate'] = _selectedDate.toIso8601String();

      final fileStream = http.ByteStream(_screenshot!.openRead());
      final length = await _screenshot!.length();
      final multipartFile = http.MultipartFile(
        'screenshotImage',
        fileStream,
        length,
        filename: _screenshot!.path.split('/').last,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = jsonDecode(response.body);
        if (resData['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Screenshot uploaded successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } else {
          throw Exception(resData['message'] ?? 'Failed to upload screenshot');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save to server: $e. Opening WhatsApp anyway...',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }

    final formattedDate =
        "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}";
    final amount = _amountController.text;

    final message =
        "Hi! I have made a payment of ₹$amount on $formattedDate "
        "for booking ID: ${widget.displayBookingId}. "
        "Please verify the payment.\n\n"
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

    if (mounted) {
      Navigator.pop(context); // Close Dialog
    }

    // Inform user to attach screenshot
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Opening WhatsApp. Please attach your selected screenshot in the chat!',
          ),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.teal,
        ),
      );
    }

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
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitAndLaunchWhatsApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isSubmitting
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Send via WhatsApp',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const String _whatsappSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512" fill="white">
  <path d="M380.9 97.1C339 55.1 283.2 32 223.9 32c-122.4 0-222 99.6-222 222 0 39.1 10.2 77.3 29.6 111L3.9 480l117.7-30.9c32.4 17.7 68.9 27 106.1 27h.1c122.3 0 224.1-99.6 224.1-222 0-59.3-25.2-115-67.1-157zm-157 341.6c-33.2 0-65.7-8.9-94-25.7l-6.7-4-69.8 18.3L72 359.2l-4.4-7c-18.5-29.4-28.2-63.3-28.2-98.2 0-101.7 82.8-184.5 184.6-184.5 49.3 0 95.6 19.2 130.4 54.1 34.8 34.9 56.2 81.2 56.1 130.5 0 101.8-84.9 184.6-186.6 184.6zm101.2-138.2c-5.5-2.8-32.8-16.2-37.9-18-5.1-1.9-8.8-2.8-12.5 2.8-3.7 5.6-14.3 18-17.6 21.8-3.2 3.7-6.5 4.2-12 1.4-32.6-16.3-54-29.1-75.5-66-5.7-9.8 5.7-9.1 16.3-30.3 1.8-3.7.9-6.9-.5-9.7-1.4-2.8-12.5-30.1-17.1-41.2-4.5-10.8-9.1-9.3-12.5-9.5-3.2-.2-6.9-.2-10.6-.2-3.7 0-9.7 1.4-14.8 6.9-5.1 5.6-19.4 19-19.4 46.3 0 27.3 19.9 53.7 22.6 57.4 2.8 3.7 39.1 59.7 94.8 83.8 35.2 15.2 49 16.5 66.6 13.9 10.7-1.6 32.8-13.4 37.4-26.4 4.6-13 4.6-24.1 3.2-26.4-1.3-2.5-5-3.9-10.5-6.6z"/>
</svg>
''';
