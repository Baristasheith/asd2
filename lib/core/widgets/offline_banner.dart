import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../localization/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Wraps `child` and slides down a thin "No internet connection" banner
/// whenever connectivity drops, on top of everything else in the app.
/// Firestore itself queues writes locally and syncs automatically once
/// back online — this banner exists purely so the person isn't confused
/// about why things look momentarily stale.
class OfflineBanner extends StatefulWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((results) {
      final offline = results.every((r) => r == ConnectivityResult.none);
      if (mounted) setState(() => _isOffline = offline);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedSlide(
            duration: AppConstants.mediumAnim,
            offset: _isOffline ? Offset.zero : const Offset(0, -1.2),
            curve: Curves.easeOut,
            child: SafeArea(
              bottom: false,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd, vertical: AppConstants.spaceSm),
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd, vertical: AppConstants.spaceSm),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off, size: 16, color: Colors.white),
                    const SizedBox(width: AppConstants.spaceSm),
                    Text(
                      l10n?.noInternetConnection ?? 'No internet connection',
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
