import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/user.dart';
import 'repo_data_export_service.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  late Box<User> usersBox;
  late Box<String> sessionBox;

  Future<void> init() async {
    usersBox = Hive.box<User>('users');
    sessionBox = Hive.box<String>('session');
  }

  String _hashPassword(String password) {
    return sha256.convert(password.codeUnits).toString();
  }

  String _generateParticipantId() {
    // Short human-readable ID while still using UUID randomness.
    return 'PT-${const Uuid().v4().replaceAll('-', '').substring(0, 8).toUpperCase()}';
  }

  Future<User?> signup({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (name.trim().isEmpty ||
        normalizedEmail.isEmpty ||
        password.trim().isEmpty) {
      return null;
    }

    final existingUser = usersBox.values.firstWhere(
      (user) => user.email.toLowerCase() == normalizedEmail,
      orElse: () => User(
        id: '',
        name: '',
        email: '',
        passwordHash: '',
        role: UserRole.participant,
        createdAt: DateTime.now(),
      ),
    );

    if (existingUser.id.isNotEmpty) {
      return null; // User already exists
    }

    final user = User(
      id: const Uuid().v4(),
      name: name,
      email: normalizedEmail,
      passwordHash: _hashPassword(password),
      role: role,
      createdAt: DateTime.now(),
      participantId: role == UserRole.participant
          ? _generateParticipantId()
          : '',
    );

    await usersBox.put(user.id, user);
    await sessionBox.put('currentUserId', user.id);
    await RepoDataExportService.instance.appendRecord({
      'type': 'user',
      'action': 'signup',
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'role': user.role.name,
      'createdAt': user.createdAt.toIso8601String(),
      'participantId': user.participantId,
      'timestamp': DateTime.now().toIso8601String(),
    });
    return user;
  }

  Future<User?> login({required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();

    final user = usersBox.values.firstWhere(
      (u) =>
          u.email.toLowerCase() == normalizedEmail &&
          u.passwordHash == _hashPassword(password),
      orElse: () => User(
        id: '',
        name: '',
        email: '',
        passwordHash: '',
        role: UserRole.participant,
        createdAt: DateTime.now(),
      ),
    );

    if (user.id.isEmpty) {
      return null; // Invalid credentials
    }

    await sessionBox.put('currentUserId', user.id);
    await RepoDataExportService.instance.appendRecord({
      'type': 'session',
      'action': 'login',
      'userId': user.id,
      'timestamp': DateTime.now().toIso8601String(),
    });
    return user;
  }

  Future<void> logout() async {
    await sessionBox.delete('currentUserId');
    await RepoDataExportService.instance.appendRecord({
      'type': 'session',
      'action': 'logout',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  User? getCurrentUser() {
    final userId = sessionBox.get('currentUserId');
    if (userId == null) {
      return null;
    }
    return usersBox.get(userId);
  }

  bool isLoggedIn() {
    return getCurrentUser() != null;
  }
}
