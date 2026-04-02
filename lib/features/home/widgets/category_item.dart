import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CategoryItem extends StatelessWidget {
  final String name;
  final String image;
  final Color color;
  final VoidCallback onTap;

  const CategoryItem({
    super.key,
    required this.name,
    required this.image,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // Container(
          //   padding: const EdgeInsets.all(10),
          //   decoration: BoxDecoration(
          //     color: color.withOpacity(0.1),
          //     borderRadius: BorderRadius.circular(16),
          //   ),
          // child:
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                image.isNotEmpty
                    ? Image.network(
                      image,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              Icon(Icons.category, color: color, size: 32),
                    )
                    : Icon(Icons.category, color: color, size: 32),
          ),
          // ),
          const SizedBox(height: 8),
          Text(
            name,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
