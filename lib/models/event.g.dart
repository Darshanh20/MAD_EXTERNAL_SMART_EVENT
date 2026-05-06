// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventAdapter extends TypeAdapter<Event> {
  @override
  final int typeId = 0;

  @override
  Event read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Event(
      id: fields[0] as String,
      managerId: fields[1] as String? ?? '',
      name: fields[2] as String,
      dateTime: fields[3] as DateTime,
      maxCapacity: fields[4] as int,
      checkedInCount: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.managerId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.dateTime)
      ..writeByte(4)
      ..write(obj.maxCapacity)
      ..writeByte(5)
      ..write(obj.checkedInCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
