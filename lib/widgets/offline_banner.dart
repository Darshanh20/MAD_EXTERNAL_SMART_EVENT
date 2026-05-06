import 'dart:async';

import 'package:flutter/material.dart';

import '../services/sync_service.dart';

class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _showOnlineBanner = false;
  bool? _lastOnlineState;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showBriefOnlineBanner() {
    _timer?.cancel();
    if (!mounted) {
      return;
    }

    setState(() {
      _showOnlineBanner = true;
    });

    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _showOnlineBanner = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: SyncService.instance.isOnline,
      initialData: SyncService.instance.currentlyOnline,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? SyncService.instance.currentlyOnline;

        if (_lastOnlineState != isOnline) {
          final previous = _lastOnlineState;
          _lastOnlineState = isOnline;

          if (previous == false && isOnline) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _showBriefOnlineBanner();
              }
            });
          }

          if (!isOnline) {
            _timer?.cancel();
            _showOnlineBanner = false;
          }
        }

        if (!isOnline) {
          return Container(
            width: double.infinity,
            color: Colors.amber.shade700,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: const Text(
              'Offline — check-ins saved locally',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        if (!_showOnlineBanner) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          color: Colors.green.shade700,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: const Text(
            'Back online — syncing...',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        );
      },
    );
  }
}
