import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'hive_service.dart';

class SyncService {
  SyncService._internal();

  static final SyncService instance = SyncService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _onlineController =
      StreamController<bool>.broadcast();

  StreamSubscription<dynamic>? _connectivitySubscription;
  bool _currentlyOnline = false;
  bool _initialized = false;

  Stream<bool> get isOnline => _onlineController.stream;

  bool get currentlyOnline => _currentlyOnline;

  Future<void> init() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    final initialResults = await _connectivity.checkConnectivity();
    _setConnectivityState(_hasConnection(initialResults));

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      _setConnectivityState(_hasConnection(results));
    });
  }

  Future<void> syncPendingData() async {
    final pendingParticipants = HiveService.instance.participantsBox.values
        .where((participant) => !participant.isSynced)
        .toList();

    if (pendingParticipants.isEmpty) {
      print('[SYNC] No pending participants to sync.');
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 500));

    for (final participant in pendingParticipants) {
      participant.isSynced = true;
      await HiveService.instance.saveParticipant(participant);
      print(
        '[SYNC] Synced participant ${participant.id} for event ${participant.eventId}',
      );
    }
  }

  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    await _onlineController.close();
  }

  void _setConnectivityState(bool online) {
    final previous = _currentlyOnline;
    _currentlyOnline = online;
    _onlineController.add(online);

    if (!previous && online) {
      syncPendingData();
    }
  }

  bool _hasConnection(dynamic results) {
    if (results is ConnectivityResult) {
      return results != ConnectivityResult.none;
    }

    if (results is Iterable) {
      return results.any(
        (value) =>
            value is ConnectivityResult && value != ConnectivityResult.none,
      );
    }

    return results != null;
  }
}
