import 'package:hive/hive.dart';

part 'event.g.dart';

@HiveType(typeId: 0)
class Event {
  Event({
    required this.id,
    required this.managerId,
    required this.name,
    required this.dateTime,
    required this.maxCapacity,
    required this.checkedInCount,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String managerId;

  @HiveField(2)
  String name;

  @HiveField(3)
  DateTime dateTime;

  @HiveField(4)
  int maxCapacity;

  @HiveField(5)
  int checkedInCount;

  Event copyWith({
    String? id,
    String? managerId,
    String? name,
    DateTime? dateTime,
    int? maxCapacity,
    int? checkedInCount,
  }) {
    return Event(
      id: id ?? this.id,
      managerId: managerId ?? this.managerId,
      name: name ?? this.name,
      dateTime: dateTime ?? this.dateTime,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      checkedInCount: checkedInCount ?? this.checkedInCount,
    );
  }
}
