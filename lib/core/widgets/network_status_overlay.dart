import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class NetworkStatusOverlay extends StatelessWidget {
  final Widget child;

  const NetworkStatusOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Consumer<ConnectivityProvider>(
          builder: (context, connectivity, _) {
            final isOffline = !connectivity.isConnected;
            final isReconnected = connectivity.isReconnected;
            final showBanner = isOffline || isReconnected;

            return Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  reverseDuration: const Duration(milliseconds: 250),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -1),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: showBanner
                      ? _buildBanner(
                          context: context,
                          isOffline: isOffline,
                          connectivity: connectivity,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBanner({
    required BuildContext context,
    required bool isOffline,
    required ConnectivityProvider connectivity,
  }) {
    final backgroundColor = isOffline
        ? const Color(0xFF1F1F24)
        : const Color(0xFF142B1F);
    final borderColor = isOffline
        ? AppColors.error.withValues(alpha: 0.4)
        : AppColors.success.withValues(alpha: 0.5);
    final iconColor = isOffline ? AppColors.error : AppColors.success;
    final iconBgColor = isOffline
        ? AppColors.error.withValues(alpha: 0.15)
        : AppColors.success.withValues(alpha: 0.18);

    return Dismissible(
      key: ValueKey(isOffline ? 'offline_banner' : 'online_banner'),
      direction: DismissDirection.up,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Material(
          elevation: 6,
          shadowColor: Colors.black26,
          borderRadius: BorderRadius.circular(16),
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: (isOffline ? AppColors.error : AppColors.success)
                      .withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isOffline
                        ? Icons.wifi_off_rounded
                        : Icons.wifi_rounded,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Text
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOffline
                            ? 'No Internet Connection'
                            : 'Back Online!',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isOffline
                            ? 'Please check Wi-Fi or mobile data'
                            : 'Connection restored successfully',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),

                // Retry Button (when offline)
                if (isOffline)
                  connectivity.isChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white70,
                            ),
                          ),
                        )
                      : TextButton(
                          onPressed: () => connectivity.checkConnection(),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Retry',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
