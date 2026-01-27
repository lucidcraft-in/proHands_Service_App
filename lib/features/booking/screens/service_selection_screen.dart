import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import 'booking_checkout_screen.dart';

class ServiceSelectionScreen extends StatelessWidget {
  final String categoryName;

  const ServiceSelectionScreen({
    super.key,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    // Generate some dummy services based on the category
    final services = [
      {'name': '$categoryName Basic', 'price': 25.0},
      {'name': '$categoryName Standard', 'price': 45.0},
      {'name': '$categoryName Premium', 'price': 75.0},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(categoryName, style: AppTextStyles.h4),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.settings_outlined, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service['name'] as String, style: AppTextStyles.labelLarge),
                      const SizedBox(height: 4),
                      Text('\$${(service['price'] as double).toStringAsFixed(2)}', 
                        style: AppTextStyles.priceMedium.copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),
                CustomButton(
                  text: 'Select',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BookingCheckoutScreen(
                          serviceName: service['name'] as String,
                          price: service['price'] as double,
                        ),
                      ),
                    );
                  },
                  width: 80,
                  height: 36,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
