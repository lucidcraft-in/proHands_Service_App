import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';

class BookingCheckoutScreen extends StatefulWidget {
  final String serviceName;
  final double price;

  const BookingCheckoutScreen({
    super.key,
    required this.serviceName,
    required this.price,
  });

  @override
  State<BookingCheckoutScreen> createState() => _BookingCheckoutScreenState();
}

class _BookingCheckoutScreenState extends State<BookingCheckoutScreen> {
  String _selectedPaymentMethod = 'Credit Card';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Checkout', style: AppTextStyles.h4),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            Text('Order Summary', style: AppTextStyles.labelLarge),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.serviceName, style: AppTextStyles.bodyMedium),
                      Text('\$${widget.price.toStringAsFixed(2)}', 
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal', style: AppTextStyles.bodySmall),
                      Text('\$${widget.price.toStringAsFixed(2)}', style: AppTextStyles.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tax (5%)', style: AppTextStyles.bodySmall),
                      Text('\$${(widget.price * 0.05).toStringAsFixed(2)}', style: AppTextStyles.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: AppTextStyles.labelLarge),
                      Text(
                        '\$${(widget.price * 1.05).toStringAsFixed(2)}',
                        style: AppTextStyles.h4.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Payment Method
            Text('Payment Method', style: AppTextStyles.labelLarge),
            const SizedBox(height: 16),
            _buildPaymentOption('Credit Card', Iconsax.card),
            const SizedBox(height: 12),
            _buildPaymentOption('Wallet', Iconsax.wallet),
            const SizedBox(height: 12),
            _buildPaymentOption('Cash on Service', Iconsax.money),

            const SizedBox(height: 40),

            GradientButton(
              text: _isProcessing ? 'Processing...' : 'Pay Now',
              onPressed: _isProcessing ? null : _handlePayment,
              isLoading: _isProcessing,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, IconData icon) {
    final isSelected = _selectedPaymentMethod == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePayment() async {
    setState(() => _isProcessing = true);
    
    // Simulate payment process
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() => _isProcessing = false);
      
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 60),
              const SizedBox(height: 16),
              Text('Payment Successful!', style: AppTextStyles.h4),
              const SizedBox(height: 8),
              Text(
                'Your booking has been confirmed.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 24),
              GradientButton(
                text: 'View Booking',
                onPressed: () {
                  Navigator.of(context).pop(); // Pop dialog
                  Navigator.of(context).pop(); // Pop checkout
                  // In a real app, you'd navigate to the detail screen here
                },
                width: double.infinity,
              ),
            ],
          ),
        ),
      );
    }
  }
}
