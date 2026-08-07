import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/providers/quotation_provider.dart';
import '../../../core/models/quotation_model.dart';
import '../../../core/widgets/empty_state_widget.dart';
import 'service_boy_quotation_details_screen.dart';

class ServiceBoyQuotationsListScreen extends StatefulWidget {
  const ServiceBoyQuotationsListScreen({super.key});

  @override
  State<ServiceBoyQuotationsListScreen> createState() =>
      _ServiceBoyQuotationsListScreenState();
}

class _ServiceBoyQuotationsListScreenState
    extends State<ServiceBoyQuotationsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuotationProvider>().fetchQuotations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Quote Requests', style: AppTextStyles.h4),
        centerTitle: true,
      ),
      body: Consumer<QuotationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error loading quote requests', style: AppTextStyles.h4),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      provider.error!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchQuotations(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          if (provider.quotations.isEmpty) {
            return EmptyStateWidget(
              icon: Iconsax.document_text,
              title: 'No Quote Requests',
              subtitle:
                  'You have not been assigned any quotation requests yet.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchQuotations(showSilent: true),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: provider.quotations.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final quotation = provider.quotations[index];
                return _TechnicianQuotationCard(quotation: quotation);
              },
            ),
          );
        },
      ),
    );
  }
}

class _TechnicianQuotationCard extends StatelessWidget {
  final QuotationModel quotation;

  const _TechnicianQuotationCard({required this.quotation});

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
      case QuotationStatus.created:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(quotation.status);
    final statusLabel = quotation.status.getDisplayStatus(true);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    ServiceBoyQuotationDetailsScreen(quotation: quotation),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
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
                  '#${quotation.quotationId.isNotEmpty ? quotation.quotationId : "QT..."}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
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
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Iconsax.document_text,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quotation.serviceName ?? 'Requested Service',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (quotation.createdAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Assigned: ${quotation.createdAt!.substring(0, 10)}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (quotation.amount != null)
                  Text(
                    '₹${quotation.amount!.toStringAsFixed(0)}',
                    style: AppTextStyles.h4.copyWith(
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Iconsax.location,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    quotation.location.locationName,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (quotation.description != null &&
                quotation.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Iconsax.note_2,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      quotation.description!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
