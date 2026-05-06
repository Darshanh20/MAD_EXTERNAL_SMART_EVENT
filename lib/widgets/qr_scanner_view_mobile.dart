import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScannerView extends StatefulWidget {
  const QrScannerView({super.key, required this.onScanned, this.onError});

  final Future<void> Function(String scannedId) onScanned;
  final void Function(String message)? onError;

  @override
  State<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<QrScannerView> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _qrController;
  StreamSubscription<Barcode>? _scanSubscription;
  bool _processingScan = false;

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _qrController?.dispose();
    super.dispose();
  }

  Future<void> _handleScan(String scannedId) async {
    if (_processingScan || scannedId.trim().isEmpty) {
      return;
    }

    _processingScan = true;
    try {
      await _qrController?.pauseCamera();
      await widget.onScanned(scannedId);
      await Future<void>.delayed(const Duration(milliseconds: 600));
      await _qrController?.resumeCamera();
    } catch (e) {
      widget.onError?.call('Unable to start camera scanner.');
    } finally {
      _processingScan = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!(defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS)) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'QR scanning is available on mobile devices.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: QRView(
        key: _qrKey,
        onQRViewCreated: (controller) {
          _qrController = controller;
          _scanSubscription?.cancel();
          _scanSubscription = controller.scannedDataStream.listen((scanData) {
            final code = scanData.code;
            if (code != null) {
              unawaited(_handleScan(code));
            }
          });
        },
        overlay: QrScannerOverlayShape(
          borderColor: Theme.of(context).colorScheme.primary,
          borderRadius: 16,
          borderLength: 24,
          borderWidth: 8,
          cutOutSize: 260,
        ),
        onPermissionSet: (controller, permission) {
          if (!permission) {
            widget.onError?.call('Camera permission needed to scan QR codes.');
          }
        },
      ),
    );
  }
}
