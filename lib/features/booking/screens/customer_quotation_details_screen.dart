import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/providers/quotation_provider.dart';
import '../../../core/models/quotation_model.dart';
import '../../../../core/widgets/full_screen_image_viewer.dart';

class CustomerQuotationDetailsScreen extends StatefulWidget {
  final QuotationModel quotation;

  const CustomerQuotationDetailsScreen({super.key, required this.quotation});

  @override
  State<CustomerQuotationDetailsScreen> createState() =>
      _CustomerQuotationDetailsScreenState();
}

class _CustomerQuotationDetailsScreenState
    extends State<CustomerQuotationDetailsScreen> {
  late QuotationModel _currentQuotation;
  bool _isRefreshing = false;
  String? _selectedTechnicianId;

  @override
  void initState() {
    super.initState();
    print("the quotation is :${widget.quotation.toJson()}");
    _currentQuotation = widget.quotation;
    _autoSelectTechnician(_currentQuotation);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDetails();
    });
  }

  void _autoSelectTechnician(QuotationModel q) {
    if (_selectedTechnicianId != null) return;
    for (var tech in q.requestedTechnicians) {
      if (tech.status == 'ACCEPTED') {
        _selectedTechnicianId = tech.technicianId;
        return;
      }
    }
    for (var tech in q.requestedTechnicians) {
      if (tech.status == 'SUBMITTED' || tech.amount != null) {
        _selectedTechnicianId = tech.technicianId;
        return;
      }
    }
  }

  Future<void> _fetchDetails() async {
    if (!mounted) return;
    setState(() {
      _isRefreshing = true;
    });
    try {
      final quotation = await context
          .read<QuotationProvider>()
          .fetchQuotationDetails(widget.quotation.id);
      if (quotation != null && mounted) {
        setState(() {
          _currentQuotation = quotation;
          _autoSelectTechnician(quotation);
        });
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Color _getStatusColor(QuotationStatus status) {
    switch (status) {
      case QuotationStatus.requested:
        return Colors.orange;
      case QuotationStatus.assignedToTechnician:
      case QuotationStatus.quotationGiven:
        return Colors.blue;
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

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressTracker(QuotationStatus status) {
    int currentStep = 0;
    switch (status) {
      case QuotationStatus.requested:
        currentStep = 0;
        break;
      case QuotationStatus.assignedToTechnician:
        currentStep = 1;
        break;
      case QuotationStatus.quotationGiven:
        currentStep = 2;
        break;
      case QuotationStatus.adminVerified:
        currentStep = 3;
        break;
      case QuotationStatus.accepted:
      case QuotationStatus.converted:
        currentStep = 4;
        break;
      case QuotationStatus.rejected:
        currentStep = -1;
        break;
      default:
        currentStep = 0;
    }

    final steps = [
      {'label': 'Requested', 'icon': Iconsax.document_text},
      {'label': 'Assigned', 'icon': Iconsax.user},
      {'label': 'Estimated', 'icon': Iconsax.empty_wallet},
      {'label': 'Verified', 'icon': Iconsax.shield_tick},
      {'label': 'Confirmed', 'icon': Iconsax.tick_circle},
    ];

    if (currentStep == -1) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Iconsax.close_circle5, color: Colors.red, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quotation Rejected',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'This quotation request has been rejected or cancelled.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.red.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 16),
            child: Text(
              'Request Progress',
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (index) {
              final step = steps[index];
              final isCompleted = index <= currentStep;
              final isActive = index == currentStep;

              return Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 2,
                            color:
                                index == 0
                                    ? Colors.transparent
                                    : (index <= currentStep
                                        ? AppColors.primary
                                        : AppColors.textSecondary.withOpacity(
                                          0.2,
                                        )),
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                isActive
                                    ? AppColors.primary
                                    : (isCompleted
                                        ? AppColors.primary.withOpacity(0.1)
                                        : Theme.of(
                                          context,
                                        ).scaffoldBackgroundColor),
                            border: Border.all(
                              color:
                                  isCompleted
                                      ? AppColors.primary
                                      : AppColors.textSecondary.withOpacity(
                                        0.3,
                                      ),
                              width: isActive ? 2 : 1,
                            ),
                          ),
                          child: Icon(
                            step['icon'] as IconData,
                            size: 16,
                            color:
                                isActive
                                    ? Colors.white
                                    : (isCompleted
                                        ? AppColors.primary
                                        : AppColors.textSecondary.withOpacity(
                                          0.5,
                                        )),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 2,
                            color:
                                index == steps.length - 1
                                    ? Colors.transparent
                                    : (index < currentStep
                                        ? AppColors.primary
                                        : AppColors.textSecondary.withOpacity(
                                          0.2,
                                        )),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step['label'] as String,
                      style: AppTextStyles.caption.copyWith(
                        color:
                            isCompleted
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                        fontWeight:
                            isCompleted ? FontWeight.bold : FontWeight.normal,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _rejectQuote(QuotationProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Reject Quotation', style: AppTextStyles.h4),
            content: const Text(
              'Are you sure you want to reject this quotation estimate?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Reject'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final success = await provider.rejectQuotation(_currentQuotation.id);
      if (success && mounted) {
        setState(() {
          _currentQuotation = provider.quotations.firstWhere(
            (q) => q.id == _currentQuotation.id,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quotation rejected successfully')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.submitError ?? 'Failed to reject quotation'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _selectDateTimeAndConvert(
    BuildContext context,
    QuotationProvider provider,
  ) async {
    if (_selectedTechnicianId == null &&
        _currentQuotation.requestedTechnicians.any(
          (t) => t.status == 'SUBMITTED' || t.amount != null,
        )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select a technician's estimate before accepting.",
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (pickedDate == null) return;

    if (!mounted) return;
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (pickedTime == null) return;

    final dateString =
        "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
    final timeString = pickedTime.format(context);

    final result = await provider.convertToBooking(
      quotationId: _currentQuotation.id,
      date: dateString,
      time: timeString,
      technicianId: _selectedTechnicianId,
    );

    if (result != null && mounted) {
      setState(() {
        _currentQuotation = provider.quotations.firstWhere(
          (q) => q.id == _currentQuotation.id,
        );
      });
      showDialog(
        context: context,
        barrierDismissible: false,
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
                  Text('Booking Confirmed!', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  Text(
                    'Your quotation has been accepted and converted into booking #${result['booking']?['bookingId'] ?? ''}.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Ok',
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
          content: Text(
            provider.submitError ?? 'Failed to convert quotation to booking',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuotationProvider>();
    final statusColor = _getStatusColor(_currentQuotation.status);
    final statusLabel = _currentQuotation.status.getDisplayStatus(false);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Quotation Details', style: AppTextStyles.h4),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (_isRefreshing)
            const LinearProgressIndicator(
              minHeight: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Tracker
                  _buildProgressTracker(_currentQuotation.status),
                  const SizedBox(height: 20),

                  // Service Details Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Quotation ID',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '#${_currentQuotation.quotationId.isNotEmpty ? _currentQuotation.quotationId : "QT..."}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Status',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                statusLabel,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Text(
                          _currentQuotation.serviceName ?? 'Requested Service',
                          style: AppTextStyles.h4,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentQuotation.description ??
                              'No description provided.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          Iconsax.location,
                          _currentQuotation.location.locationName,
                        ),
                        if (_currentQuotation.notes != null &&
                            _currentQuotation.notes!.isNotEmpty) ...[
                          const Divider(height: 24),
                          Text(
                            'Additional Notes',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentQuotation.notes!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Technicians & Estimates Section
                  _buildTechniciansSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Accept / Reject Actions (Visible only if status is ADMIN_VERIFIED)
          if (_currentQuotation.status == QuotationStatus.adminVerified)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedTechnicianId != null) ...[
                    Builder(
                      builder: (context) {
                        final selectedTech = _currentQuotation
                            .requestedTechnicians
                            .firstWhere(
                              (t) => t.technicianId == _selectedTechnicianId,
                              orElse:
                                  () => RequestedTechnician(
                                    technicianId: '',
                                    name: 'Selected Technician',
                                  ),
                            );
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 18,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Selected: ${selectedTech.name}${selectedTech.amount != null ? ' (₹${selectedTech.amount!.toStringAsFixed(0)})' : ''}',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _rejectQuote(provider),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(
                              color: AppColors.error,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Reject',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: 'Accept & Convert',
                          isLoading: provider.isSubmitting,
                          onPressed:
                              () =>
                                  _selectDateTimeAndConvert(context, provider),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          if (_currentQuotation.status == QuotationStatus.converted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.green.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Converted to active booking',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTechniciansSection() {
    final technicians = _currentQuotation.requestedTechnicians;
    if (technicians.isEmpty) return const SizedBox.shrink();

    final isSelectionEnabled =
        _currentQuotation.status == QuotationStatus.adminVerified;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Technician Estimates', style: AppTextStyles.h4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${technicians.length} Assigned',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isSelectionEnabled
                ? 'Select a technician to accept their estimate'
                : 'Technicians assigned to this quotation',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Divider(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: technicians.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final tech = technicians[index];
              final isSelected = _selectedTechnicianId == tech.technicianId;
              final hasEstimate =
                  tech.amount != null || tech.status == 'SUBMITTED';

              Color statusColor = Colors.orange;
              String statusText = tech.status ?? 'REQUESTED';
              if (tech.status == 'SUBMITTED' || tech.amount != null) {
                statusColor = Colors.green;
                statusText = 'ESTIMATE SENT';
              } else if (tech.status == 'ACCEPTED') {
                statusColor = Colors.teal;
                statusText = 'ACCEPTED';
              } else if (tech.status == 'REJECTED') {
                statusColor = Colors.red;
                statusText = 'REJECTED';
              }

              return InkWell(
                onTap:
                    isSelectionEnabled && hasEstimate
                        ? () {
                          setState(() {
                            _selectedTechnicianId = tech.technicianId;
                          });
                        }
                        : null,
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? AppColors.primary.withOpacity(0.05)
                            : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isSelected
                              ? AppColors.primary
                              : (hasEstimate
                                  ? AppColors.primary.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.2)),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Radio, Avatar, Name, Rating, Status
                      Row(
                        children: [
                          if (isSelectionEnabled) ...[
                            Radio<String>(
                              value: tech.technicianId,
                              groupValue: _selectedTechnicianId,
                              onChanged:
                                  hasEstimate
                                      ? (val) {
                                        setState(() {
                                          _selectedTechnicianId = val;
                                        });
                                      }
                                      : null,
                              activeColor: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                          ],
                          CircleAvatar(
                            radius: 22,
                            backgroundImage:
                                tech.profilePhoto != null &&
                                        tech.profilePhoto!.isNotEmpty
                                    ? NetworkImage(tech.profilePhoto!)
                                    : null,
                            child:
                                tech.profilePhoto == null ||
                                        tech.profilePhoto!.isEmpty
                                    ? const Icon(
                                      Icons.person,
                                      color: Colors.grey,
                                    )
                                    : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tech.name,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    if (tech.rating != null &&
                                        tech.rating! > 0) ...[
                                      const Icon(
                                        Icons.star_rounded,
                                        size: 16,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        tech.rating!.toStringAsFixed(1),
                                        style: AppTextStyles.caption.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    // if (tech.phone != null &&
                                    //     tech.phone!.isNotEmpty)
                                    //   Expanded(
                                    //     child: Text(
                                    //       tech.phone!,
                                    //       style: AppTextStyles.caption.copyWith(
                                    //         color: AppColors.textSecondary,
                                    //       ),
                                    //       maxLines: 1,
                                    //       overflow: TextOverflow.ellipsis,
                                    //     ),
                                    //   ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              statusText,
                              style: AppTextStyles.caption.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Quoted Amount
                      if (tech.amount != null) ...[
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Quoted Amount',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${tech.currency == 'INR' ? '₹' : tech.currency} ${tech.amount!.toStringAsFixed(0)}',
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Technician Notes
                      if (tech.notes.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Iconsax.note_text,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Estimate Notes:',
                                    style: AppTextStyles.caption.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ...tech.notes.map(
                                (n) => Text(
                                  n,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Technician Attachments/Images
                      if (tech.images.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Estimate Attachments:',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 70,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: tech.images.length,
                            separatorBuilder:
                                (context, i) => const SizedBox(width: 8),
                            itemBuilder: (context, i) {
                              final img = tech.images[i];
                              final tag = 'tech_img_${tech.technicianId}_$i';
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => FullScreenImageViewer(
                                            imagePath: img.url,
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
                                      img.url,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                width: 70,
                                                height: 70,
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.broken_image,
                                                  color: Colors.grey,
                                                  size: 20,
                                                ),
                                              ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],

                      if (tech.amount == null &&
                          tech.status != 'SUBMITTED') ...[
                        const SizedBox(height: 8),
                        Text(
                          'Waiting for technician to submit estimate...',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.orange,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
