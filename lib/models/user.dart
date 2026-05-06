import 'package:hive/hive.dart';

part 'user.g.dart';

enum UserRole { manager, participant }

@HiveType(typeId: 2)
class User extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String passwordHash;

  @HiveField(4)
  final String roleString; // Store as string

  @HiveField(5)
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required UserRole role,
    required this.createdAt,
  }) : roleString = role.name;

  // Convert string back to enum
  UserRole get role => UserRole.values.firstWhere((r) => r.name == roleString);
}
