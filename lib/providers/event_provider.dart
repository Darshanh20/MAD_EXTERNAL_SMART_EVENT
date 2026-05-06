import 'package:flutter/foundation.dart';

import '../models/event.dart';
import '../models/participant.dart';
import '../models/user.dart';
import '../services/hive_service.dart';

enum CheckInResult { success, alreadyCheckedIn, atCapacity, invalidId }

class EventProvider extends ChangeNotifier {
  EventProvider();

  List<Event> events = [];
  List<Participant> participants = [];
  Event? activeEvent;

  Future<void> createEvent(Event event, {required String managerId}) async {
    final ownedEvent = event.copyWith(managerId: managerId);
    await HiveService.instance.saveEvent(ownedEvent);
    events = HiveService.instance.getEventsByManager(managerId);
    activeEvent = ownedEvent;
    notifyListeners();
  }

  Future<void> loadEvents({
    required UserRole role,
    required String userId,
  }) async {
    events = role == UserRole.manager
        ? HiveService.instance.getEventsByManager(userId)
        : HiveService.instance.getAllEvents();
    notifyListeners();
  }

  Future<List<Participant>> loadParticipants(String eventId) async {
    participants = HiveService.instance.getParticipantsForEvent(eventId);
    notifyListeners();
    return participants;
  }

  CheckInResult checkInParticipant(
    String participantId,
    String name,
    Event event,
  ) {
    final sanitizedId = participantId.trim();
    final existingParticipant = HiveService.instance.participantsBox.values
        .firstWhere(
          (participant) =>
              participant.id == sanitizedId && participant.eventId == event.id,
          orElse: () => Participant(
            id: '',
            name: '',
            eventId: '',
            isCheckedIn: false,
            checkInTime: null,
          ),
        );

    if (existingParticipant.id.isNotEmpty && existingParticipant.isCheckedIn) {
      return CheckInResult.alreadyCheckedIn;
    }

    if (event.checkedInCount >= event.maxCapacity) {
      return CheckInResult.atCapacity;
    }

    if (sanitizedId.isEmpty) {
      return CheckInResult.invalidId;
    }

    final participant = Participant(
      id: sanitizedId,
      name: name.trim().isEmpty ? sanitizedId : name.trim(),
      eventId: event.id,
      isCheckedIn: true,
      checkInTime: DateTime.now(),
      isSynced: false,
    );

    HiveService.instance.saveParticipant(participant);

    event.checkedInCount += 1;
    activeEvent = event;
    HiveService.instance.saveEvent(event);

    participants = HiveService.instance.getParticipantsForEvent(event.id);
    notifyListeners();
    return CheckInResult.success;
  }

  List<Participant> searchParticipants(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return participants;
    }

    return participants.where((participant) {
      return participant.id.toLowerCase().contains(normalizedQuery) ||
          participant.name.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  List<Participant> searchParticipantsForEvent(String eventId, String query) {
    final eventParticipants = HiveService.instance.getParticipantsForEvent(
      eventId,
    );
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return eventParticipants;
    }

    return eventParticipants.where((participant) {
      return participant.id.toLowerCase().contains(normalizedQuery) ||
          participant.name.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  Event? getEventById(String eventId) {
    for (final event in events) {
      if (event.id == eventId) {
        return event;
      }
    }
    return null;
  }
}
