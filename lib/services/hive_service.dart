import 'package:hive/hive.dart';

import '../models/event.dart';
import '../models/participant.dart';

class HiveService {
  HiveService._internal();

  static final HiveService instance = HiveService._internal();

  Box<Event> get eventsBox => Hive.box<Event>('events');

  Box<Participant> get participantsBox => Hive.box<Participant>('participants');

  Future<void> saveEvent(Event event) async {
    await eventsBox.put(event.id, event);
  }

  Future<void> saveParticipant(Participant participant) async {
    await participantsBox.put(participant.id, participant);
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
  }
}
