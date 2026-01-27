import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<CartItem> _cartItems = [
    CartItem(
      serviceName: 'Ac cleaning service',
      price: 30.0,
      discount: 10,
      providerName: 'Kurt Bates',
      rating: 3.0,
      date: '25 Jan, 2024',
      time: '06:30 AM',
      servicemenCount: 1,
    ),
    CartItem(
      serviceName: 'Furnishing & carpentry',
      price: 15.23,
      discount: 0,
      providerName: 'Kurt Bates',
      rating: 4.0,
      date: '25 Jan, 2024',
      time: '06:30 PM',
      servicemenCount: 1,
    ),
  ];

  double get _subtotal {
    return _cartItems.fold(0, (sum, item) => sum + item.price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'My cart (${_cartItems.length})',
          style: AppTextStyles.h4,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _cartItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                return _CartItemCard(
                  item: item,
                  onEdit: () {},
                  onDelete: () {
                    setState(() => _cartItems.removeAt(index));
                  },
                );
              },
            ),
          ),
          
          // Bottom section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sub total',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '\$${_subtotal.toStringAsFixed(2)}',
                        style: AppTextStyles.priceLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GradientButton(
                    text: 'Proceed to checkout',
                    icon: Icons.arrow_forward,
                    onPressed: () {},
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CartItem {
  final String serviceName;
  final double price;
  final int discount;
  final String providerName;
  final double rating;
  final String date;
  final String time;
  final int servicemenCount;

  CartItem({
    required this.serviceName,
    required this.price,
    required this.discount,
    required this.providerName,
    required this.rating,
    required this.date,
    required this.time,
    required this.servicemenCount,
  });
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CartItemCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          // Provider header
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.background,
                child: Icon(Icons.person, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.providerName,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.star, color: Color(0xFFFFA928), size: 16),
              const SizedBox(width: 4),
              Text(
                item.rating.toString(),
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Iconsax.edit_2, size: 18),
                onPressed: onEdit,
                color: AppColors.textTertiary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                onPressed: onDelete,
                color: AppColors.error,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.cleaning_services,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.serviceName,
                      style: AppTextStyles.labelLarge.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: AppTextStyles.priceMedium.copyWith(
                            fontSize: 16,
                          ),
                        ),
                        if (item.discount > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '(${item.discount}.00%)',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          
          Row(
            children: [
              const Icon(Iconsax.calendar, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('${item.date}   ', style: AppTextStyles.bodySmall),
              const Icon(Iconsax.clock, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(item.time, style: AppTextStyles.bodySmall),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected servicemen :',
                style: AppTextStyles.caption,
              ),
              Text(
                '${item.servicemenCount} servicemen',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.info_circle, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'As you previously said, the app will select your servicemen.',
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
