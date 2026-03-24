import 'dart:async';
import '../models/user_model.dart';
import '../../domain/entities/user_entity.dart';
import '../../core/constants/app_constants.dart';
import 'backend_client.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  });

  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get userStream;
  Future<void> updateEmergencyContacts(String userId, List<ContactEntity> contacts);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final BackendClient _client = BackendClient();
  UserModel? _currentUser;
  final _userStreamController = StreamController<UserModel?>.broadcast();

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final res = await _client.post('/auth/login', {
      'email': email,
      'password': password,
    });
    
    _currentUser = UserModel.fromJson(res);
    _userStreamController.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    final res = await _client.post('/auth/register', {
      'email': email,
      'password': password,
      'name': fullName,
      'role': role.name.toUpperCase(),
    });

    _currentUser = UserModel.fromJson(res);
    _userStreamController.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _userStreamController.add(null);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Stream<UserModel?> get userStream => _userStreamController.stream;

  @override
  Future<void> updateEmergencyContacts(String userId, List<ContactEntity> contacts) async {
    await _client.patch('/users/$userId/emergency-contacts', {
      'contacts': contacts.map((c) => {'name': c.name, 'phoneNumber': c.phoneNumber}).toList(),
    });
  }
}
