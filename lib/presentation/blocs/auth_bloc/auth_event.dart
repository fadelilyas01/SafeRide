import 'package:equatable/equatable.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthUserChanged extends AuthEvent {
  final UserEntity? user;
  const AuthUserChanged(this.user);

  @override
  List<Object> get props => [user ?? 'null'];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;
  const SignInRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final UserRole role;
  const SignUpRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.role,
  });

  @override
  List<Object> get props => [email, password, fullName, role];
}

class SignOutRequested extends AuthEvent {}

class UpdateEmergencyContactsRequested extends AuthEvent {
  final List<ContactEntity> contacts;
  const UpdateEmergencyContactsRequested(this.contacts);

  @override
  List<Object> get props => [contacts];
}
