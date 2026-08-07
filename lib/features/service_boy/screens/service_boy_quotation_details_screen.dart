import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/providers/quotation_provider.dart';
import '../../../core/models/quotation_model.dart';
import '../../../../core/widgets/full_screen_image_viewer.dart';

class ServiceBoyQuotationDetailsScreen extends StatefulWidget {
  final QuotationModel quotation;

  const ServiceBoyQuotationDetailsScreen({super.key, required this.quotation});

  @override
  State<ServiceBoyQuotationDetailsScreen> createState() =>
      _ServiceBoyQuotationDetailsScreenState();
}

class _ServiceBoyQuotationDetailsScreenState
    extends State<ServiceBoyQuotationDetailsScreen> {
  late QuotationModel _currentQuotation;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final List<String> _attachments = [];
  final List<File> _selectedImages = [];
  final _picker = ImagePicker();
  bool _isUploadingLocal = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _currentQuotation = widget.quotation;
    if (_currentQuotation.amount != null) {
      _amountController.text = _currentQuotation.amount!.toStringAsFixed(0);
    }
    if (_currentQuotation.technicianNote != null) {
      _noteController.text = _currentQuotation.technicianNote!;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Color _getStatusColor(QuotationStatus status) {
    switch (status) {
      case QuotationStatus.requested:
        return Colors.orange;
      case QuotationStatus.assignedToTechnician:
        return Colors.blue;
      case QuotationStatus.quotationGiven:
        return Colors.purple;
      case QuotationStatus.adminVerified:
        return Colors.green;
      case QuotationStatus.rejected:
        return Colors.red;
      case QuotationStatus.converted:
        return AppColors.primary;
      case QuotationStatus.accepted:
        return Colors.teal;
      case QuotationStatus.expired:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> images = await _picker.pickMultiImage(
          imageQuality: 70,
        );
        if (images.isNotEmpty) {
          setState(() {
            _selectedImages.addAll(images.map((img) => File(img.path)));
          });
        }
      } else {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 70,
        );
        if (image != null) {
          setState(() {
            _selectedImages.add(File(image.path));
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Iconsax.camera, color: AppColors.primary),
                title: const Text('Take Photo (Camera)'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Iconsax.image, color: AppColors.primary),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitEstimate(QuotationProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid estimate amount')),
      );
      return;
    }

    setState(() => _isUploadingLocal = true);
    List<String> uploadedUrls = [];
    try {
      if (_selectedImages.isNotEmpty) {
        uploadedUrls = await provider.uploadAttachments(
          _selectedImages.map((f) => f.path).toList(),
        );
      }
    } catch (e) {
      setState(() => _isUploadingLocal = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload attachments: $e'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    } finally {
      if (mounted) {
        setState(() => _isUploadingLocal = false);
      }
    }
    print(uploadedUrls);
    final success = await provider.submitDetails(
      quotationId: _currentQuotation.id,
      amount: amount,
      technicianNote:
          _noteController.text.trim().isNotEmpty
              ? _noteController.text.trim()
              : null,
      attachments: uploadedUrls,
    );

    if (success && mounted) {
      setState(() {
        _currentQuotation = provider.quotations.firstWhere(
          (q) => q.id == _currentQuotation.id,
        );
      });
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  const Icon(
                    Iconsax.tick_circle5,
                    color: Colors.green,
                    size: 72,
                  ),
                  const SizedBox(height: 16),
                  Text('Estimate Submitted!', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  Text(
                    'Your estimate of ₹${amount.toStringAsFixed(0)} has been submitted for admin verification.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Close',
                      onPressed: () {
                        Navigator.pop(context); // Pop dialog
                      },
                    ),
                  ),
                ],
              ),
            ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.submitError ?? 'Failed to submit estimate'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuotationProvider>();
    final statusColor = _getStatusColor(_currentQuotation.status);
    final statusLabel = _currentQuotation.status.getDisplayStatus(true);
    print(_currentQuotation.attachments);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Quote Request Details', style: AppTextStyles.h4),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status & ID Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quotation ID',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '#${_currentQuotation.quotationId.isNotEmpty ? _currentQuotation.quotationId : "QT..."}',
                              style: AppTextStyles.h4.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusLabel,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Service Requested
                  Text('Service Requested', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Text(
                      _currentQuotation.serviceName ?? 'Requested Service',
                      style: AppTextStyles.h4.copyWith(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Location
                  Text('Location Address', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Iconsax.location,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _currentQuotation.location.locationName,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text('Customer Notes', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentQuotation.description ??
                              'No description provided by customer.',
                          style: AppTextStyles.bodyMedium,
                        ),
                        if (_currentQuotation.notes != null &&
                            _currentQuotation.notes!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          Text(
                            'Extra Notes:',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentQuotation.notes!,
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Estimate details form or display
                  if (_currentQuotation.status ==
                      QuotationStatus.assignedToTechnician) ...[
                    Text(
                      'Submit Estimate Estimate',
                      style: AppTextStyles.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Form(
                      key: _formKey,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimated Price (₹)',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Enter amount (e.g. 1500)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixText: '₹ ',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter amount';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Technician Notes',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _noteController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText:
                                    'Explain the details (e.g. Needs replacement of compressor part)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Job Proof Attachments',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 80,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  GestureDetector(
                                    onTap: _showImageSourceBottomSheet,
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppColors.primary.withOpacity(
                                            0.5,
                                          ),
                                          style: BorderStyle.solid,
                                        ),
                                      ),
                                      child: const Icon(
                                        Iconsax.add_square,
                                        color: AppColors.primary,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ...List.generate(_selectedImages.length, (
                                    index,
                                  ) {
                                    final imageFile = _selectedImages[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.file(
                                              imageFile,
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _selectedImages.removeAt(
                                                    index,
                                                  );
                                                });
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  2,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: CustomButton(
                                text: 'Submit Quotation Details',
                                isLoading:
                                    provider.isSubmitting || _isUploadingLocal,
                                onPressed: () => _submitEstimate(provider),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (_currentQuotation.amount != null) ...[
                    Text('Submitted Estimate', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Estimate Amount:',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '₹${_currentQuotation.amount!.toStringAsFixed(0)}',
                                style: AppTextStyles.h3.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          if (_currentQuotation.technicianNote != null &&
                              _currentQuotation.technicianNote!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 8),
                            Text(
                              'Your Notes:',
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentQuotation.technicianNote!,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          if (_currentQuotation.attachments.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 8),
                            Text(
                              'Submitted Attachments:',
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 80,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _currentQuotation.attachments.length,
                                separatorBuilder:
                                    (context, index) =>
                                        const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final imageUrl =
                                      _currentQuotation.attachments[index];
                                  final tag =
                                      'service_boy_quotation_attachment_$index';
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  FullScreenImageViewer(
                                                    imagePath: imageUrl,
                                                    tag: tag,
                                                  ),
                                        ),
                                      );
                                    },
                                    child: Hero(
                                      tag: tag,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          imageUrl,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
