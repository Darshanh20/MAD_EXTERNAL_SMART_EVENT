import 'package:flutter/material.dart';

class QrScannerView extends StatelessWidget {
  const QrScannerView({super.key, required this.onScanned, this.onError});

  final Future<void> Function(String scannedId) onScanned;
  final void Function(String message)? onError;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'QR scanning is not available on this platform. Use Manual Entry instead.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
