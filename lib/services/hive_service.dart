import 'package:hive/hive.dart';

import '../models/event.dart';
import '../models/participant.dart';
import 'repo_data_export_service.dart';

class HiveService {
  HiveService._internal();

  static final HiveService instance = HiveService._internal();

  Box<Event> get eventsBox => Hive.box<Event>('events');

  Box<Participant> get participantsBox => Hive.box<Participant>('participants');

  Future<void> saveEvent(Event event) async {
    await eventsBox.put(event.id, event);
    await RepoDataExportService.instance.appendRecord({
      'type': 'event',
      'action': 'save',
      'id': event.id,
      'name': event.name,
      'dateTime': event.dateTime.toIso8601String(),
      'maxCapacity': event.maxCapacity,
      'checkedInCount': event.checkedInCount,
      'managerId': event.managerId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> saveParticipant(Participant participant) async {
    final scopedKey = '${participant.eventId}::${participant.id}';
    await participantsBox.put(scopedKey, participant);
    await RepoDataExportService.instance.appendRecord({
      'type': 'participant',
      'action': 'save',
      'id': participant.id,
      'name': participant.name,
      'eventId': participant.eventId,
      'isCheckedIn': participant.isCheckedIn,
      'checkInTime': participant.checkInTime?.toIso8601String(),
      'isSynced': participant.isSynced,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  List<Event> getAllEvents() => eventsBox.values.toList();

  List<Event> getEventsByManager(String managerId) {
    return eventsBox.values
        .where((event) => event.managerId == managerId)
        .toList();
  }

  List<Participant> getParticipantsForEvent(String eventId) {
    return participantsBox.values
        .where((participant) => participant.eventId == eventId)
        .toList();
  }

  Future<void> clearAll() async {
    await eventsBox.clear();
    await participantsBox.clear();
    await RepoDataExportService.instance.appendRecord({
      'type': 'system',
      'action': 'clearAll',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
