import 'package:flutter/material.dart';
import 'package:service_app/core/models/booking_log_model.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TimelineItem extends StatefulWidget {
  const TimelineItem({required this.log, required this.isLast});

  final BookingLogModel log;
  final bool isLast;

  @override
  State<TimelineItem> createState() => TimelineItemState();
}

class TimelineItemState extends State<TimelineItem> {
  bool _hovered = false;

  Color get _statusColor {
    switch ("warning") {
      case 'success':
        return const Color(0xFF1D9E75);
      case 'warning':
        return const Color(0xFFEF9F27);
      case 'danger':
        return const Color(0xFFE24B4A);
      case 'info':
      default:
        return const Color(0xFF378ADD);
    }
  }

  String get _badgeLabel {
    switch ("info") {
      case 'success':
        return 'Completed';
      case 'warning':
        return 'Pending';
      case 'danger':
        return 'Cancelled';
      case 'info':
      default:
        return 'Note';
    }
  }

  Color get _badgeBg {
    switch ("success") {
      case 'success':
        return const Color(0xFFE1F5EE);
      case 'warning':
        return const Color(0xFFFAEEDA);
      case 'danger':
        return const Color(0xFFFCEBEB);
      case 'info':
      default:
        return const Color(0xFFE6F1FB);
    }
  }

  Color get _badgeTextColor {
    switch ("success") {
      case 'success':
        return const Color(0xFF0F6E56);
      case 'warning':
        return const Color(0xFF854F0B);
      case 'danger':
        return const Color(0xFFA32D2D);
      case 'info':
      default:
        return const Color(0xFF185FA5);
    }
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = _monthAbbr(dt.month);
      final hour = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '$day $month ${dt.year}, $hour:$min';
    } catch (_) {
      return raw;
    }
  }

  String _monthAbbr(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column: dot + line
          SizedBox(
            width: 36,
            child: Column(
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _statusColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _statusColor.withOpacity(0.25),
                            blurRadius: 0,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!widget.isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Right column: card
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 8, bottom: widget.isLast ? 0 : 16),
              child: MouseRegion(
                onEnter: (_) => setState(() => _hovered = true),
                onExit: (_) => setState(() => _hovered = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          _hovered
                              ? Theme.of(context).dividerColor.withOpacity(0.5)
                              : Theme.of(
                                context,
                              ).dividerColor.withOpacity(0.25),
                      width: 0.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Note + badge row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.log.notes,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                                height: 1.45,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? _statusColor.withOpacity(0.15)
                                      : _badgeBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _badgeLabel,
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark ? _statusColor : _badgeTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Meta row
                      Wrap(
                        spacing: 14,
                        runSpacing: 4,
                        children: [
                          _MetaChip(
                            icon: Icons.access_time_rounded,
                            label: _formatDate(widget.log.createdAt),
                          ),
                          _MetaChip(
                            icon: Icons.person_outline_rounded,
                            label: widget.log.createdByName,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary.withOpacity(0.7)),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
