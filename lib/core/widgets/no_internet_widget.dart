import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class NoInternetWidget extends StatefulWidget {
  final VoidCallback? onRetry;
  final String? message;

  const NoInternetWidget({
    super.key,
    this.onRetry,
    this.message,
  });

  @override
  State<NoInternetWidget> createState() => _NoInternetWidgetState();
}

class _NoInternetWidgetState extends State<NoInternetWidget> {
  bool _wasOffline = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isConnected = context.watch<ConnectivityProvider>().isConnected;
    if (!isConnected) {
      _wasOffline = true;
    } else if (_wasOffline && isConnected) {
      // Auto-reconnected: automatically trigger retry callback!
      _wasOffline = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onRetry?.call();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityProvider>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 56,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Internet Connection',
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              widget.message ??
                  'Please check your Wi-Fi or mobile data settings. Once reconnected, the app will resume automatically.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 160,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: connectivity.isChecking
                    ? null
                    : () {
                        connectivity.checkConnection();
                        widget.onRetry?.call();
                      },
                icon: connectivity.isChecking
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.refresh_rounded, size: 20),
                label: Text(connectivity.isChecking ? 'Checking...' : 'Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
