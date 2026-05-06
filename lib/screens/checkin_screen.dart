import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import 'dashboard_screen.dart';
import 'logs_screen.dart';
import '../widgets/offline_banner.dart';
import '../widgets/qr_scanner_view.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key, required this.event});

  final Event event;

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  int _managerTabIndex = 0;

  void _openManagerLogs() {
    if (!mounted) {
      return;
    }

    setState(() {
      _managerTabIndex = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final isManager = authProvider.userRole == UserRole.manager;
    final isManagerOwner =
        currentUser != null &&
        widget.event.managerId.isNotEmpty &&
        widget.event.managerId == currentUser.id;

    if (isManager && !isManagerOwner) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.event.name), elevation: 0),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'You do not have access to manage this event.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
      );
    }

    if (!isManager) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.event.name), elevation: 0),
        body: Column(
          children: [
            const OfflineBanner(),
            Expanded(child: _CheckInTab(event: widget.event)),
          ],
        ),
      );
    }

    final managerPages = <Widget>[
      _CheckInTab(event: widget.event),
      DashboardScreen(
        event: widget.event,
        embedded: true,
        onOpenLogs: _openManagerLogs,
      ),
      LogsScreen(event: widget.event, embedded: true),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(widget.event.name), elevation: 0),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: IndexedStack(
              index: _managerTabIndex,
              children: managerPages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _managerTabIndex,
        onDestinationSelected: (index) {
          setState(() {
            _managerTabIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined),
            selectedIcon: Icon(Icons.qr_code_scanner),
            label: 'Check-In',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Logs',
          ),
        ],
      ),
    );
  }
}

class _CheckInTab extends StatefulWidget {
  const _CheckInTab({required this.event});

  final Event event;

  @override
  State<_CheckInTab> createState() => _CheckInTabState();
}

class _CheckInTabState extends State<_CheckInTab> {
  final TextEditingController _participantIdController =
      TextEditingController();
  final TextEditingController _participantNameController =
      TextEditingController();

  bool _isParticipantIdentityLocked = false;

  String? _bannerMessage;
  Color _bannerColor = Colors.green;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    if (authProvider.userRole == UserRole.participant &&
        user != null &&
        user.participantId.isNotEmpty) {
      _participantIdController.text = user.participantId;
      _participantNameController.text = user.name;
      _isParticipantIdentityLocked = true;
    }
  }

  @override
  void dispose() {
    _participantIdController.dispose();
    _participantNameController.dispose();
    super.dispose();
  }

  void _showBanner(String message, Color color) {
    setState(() {
      _bannerMessage = message;
      _bannerColor = color;
    });

    // Auto-hide banner after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _bannerMessage = null);
      }
    });
  }

  Future<void> _showQrErrorDialog(String message) async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Camera Permission Needed'),
          content: Text(
            '$message Please grant camera permission in app settings, then try scanning again.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitManualCheckIn() async {
    final participantId = _participantIdController.text.trim();
    final participantName = _participantNameController.text.trim();

    if (participantId.isEmpty) {
      _showBanner('Participant ID is required', Colors.red);
      return;
    }

    final provider = context.read<EventProvider>();
    final result = provider.checkInParticipant(
      participantId,
      participantName.isEmpty ? participantId : participantName,
      widget.event,
    );

    switch (result) {
      case CheckInResult.success:
        _showBanner(
          'Check-in successful for ${participantName.isEmpty ? participantId : participantName}',
          Colors.green,
        );
        if (!_isParticipantIdentityLocked) {
          _participantIdController.clear();
          _participantNameController.clear();
        }
        break;
      case CheckInResult.alreadyCheckedIn:
        _showBanner('Already checked in', Colors.red);
        break;
      case CheckInResult.atCapacity:
        _showBanner('Event at full capacity', Colors.red);
        break;
      case CheckInResult.invalidId:
        _showBanner('Participant ID is required', Colors.red);
        break;
    }
  }

  Widget _buildBanner() {
    if (_bannerMessage == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bannerColor.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _bannerColor.withValues(alpha: 0.4)),
      ),
      child: Text(
        _bannerMessage!,
        style: TextStyle(color: _bannerColor, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildManualEntryTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 20),
        TextField(
          controller: _participantIdController,
          readOnly: _isParticipantIdentityLocked,
          decoration: InputDecoration(
            labelText: _isParticipantIdentityLocked
                ? 'Participant ID (Auto-assigned)'
                : 'Participant ID',
            hintText: _isParticipantIdentityLocked
                ? 'Assigned during signup'
                : 'Enter your participant ID',
            border: OutlineInputBorder(),
            prefixIcon: const Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _participantNameController,
          decoration: const InputDecoration(
            labelText: 'Name (Optional)',
            hintText: 'Enter your name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.badge),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 56,
          child: FilledButton(
            onPressed: _submitManualCheckIn,
            child: const Text('Check In'),
          ),
        ),
      ],
    );
  }

  Widget _buildQrScanner() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: QrScannerView(
              onScanned: (scannedId) async {
                try {
                  final trimmedId = scannedId.trim();
                  if (trimmedId.isEmpty) {
                    return;
                  }

                  final provider = context.read<EventProvider>();
                  final result = provider.checkInParticipant(
                    trimmedId,
                    trimmedId,
                    widget.event,
                  );

                  switch (result) {
                    case CheckInResult.success:
                      _showBanner(
                        'Check-in successful for $trimmedId',
                        Colors.green,
                      );
                      break;
                    case CheckInResult.alreadyCheckedIn:
                      _showBanner('Already checked in', Colors.red);
                      break;
                    case CheckInResult.atCapacity:
                      _showBanner('Event at full capacity', Colors.red);
                      break;
                    case CheckInResult.invalidId:
                      _showBanner('Participant ID is required', Colors.red);
                      break;
                  }
                } catch (_) {
                  await _showQrErrorDialog(
                    'Unable to process scanned QR code.',
                  );
                }
              },
              onError: (message) {
                unawaited(_showQrErrorDialog(message));
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _buildBanner(),
          ),
          const TabBar(
            tabs: [
              Tab(text: 'QR Scan', icon: Icon(Icons.qr_code_scanner)),
              Tab(text: 'Manual Entry', icon: Icon(Icons.edit_note)),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [_buildQrScanner(), _buildManualEntryTab()],
            ),
          ),
        ],
      ),
    );
  }
}
