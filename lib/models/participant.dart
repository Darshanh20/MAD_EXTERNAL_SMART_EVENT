import 'package:hive/hive.dart';

part 'participant.g.dart';

@HiveType(typeId: 1)
class Participant {
  Participant({
    required this.id,
    required this.name,
    required this.eventId,
    required this.isCheckedIn,
    required this.checkInTime,
    this.isSynced = false,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String eventId;

  @HiveField(3)
  bool isCheckedIn;

  @HiveField(4)
  DateTime? checkInTime;

  @HiveField(5)
  bool isSynced;

  Participant copyWith({
    String? id,
    String? name,
    String? eventId,
    bool? isCheckedIn,
    DateTime? checkInTime,
    bool? isSynced,
  }) {
    return Participant(
      id: id ?? this.id,
      name: name ?? this.name,
      eventId: eventId ?? this.eventId,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      checkInTime: checkInTime ?? this.checkInTime,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
