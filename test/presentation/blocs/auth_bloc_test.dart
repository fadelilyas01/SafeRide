import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saferide/domain/entities/user_entity.dart';
import 'package:saferide/domain/repositories/auth_repository.dart';
import 'package:saferide/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:saferide/presentation/blocs/auth_bloc/auth_event.dart';
import 'package:saferide/presentation/blocs/auth_bloc/auth_state.dart';
import 'package:saferide/core/constants/app_constants.dart';

// Mocktail Mock
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockAuthRepository;
  late StreamController<UserEntity?> userStreamController;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    userStreamController = StreamController<UserEntity?>();
    
    when(() => mockAuthRepository.userStream).thenAnswer((_) => userStreamController.stream);
    
    authBloc = AuthBloc(authRepository: mockAuthRepository);
  });

  tearDown(() {
    userStreamController.close();
    authBloc.close();
  });

  const tUser = UserEntity(
    id: '1',
    email: 'test@example.com',
    role: UserRole.passenger,
  );

  test('initial state should be AuthInitial', () {
    expect(authBloc.state, AuthInitial());
  });

  blocTest<AuthBloc, AuthState>(
    'emits [Authenticated] when a user is emitted on the stream',
    build: () => authBloc,
    act: (_) => userStreamController.add(tUser),
    expect: () => [
      const Authenticated(tUser),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [Unauthenticated] when null is emitted on the stream',
    build: () => authBloc,
    act: (_) => userStreamController.add(null),
    expect: () => [
      Unauthenticated(),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, Authenticated] when SignInRequested is successful',
    build: () {
      when(() => mockAuthRepository.signInWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => const Right(tUser));
      return authBloc;
    },
    act: (bloc) => bloc.add(const SignInRequested('test@example.com', 'password')),
    expect: () => [
      AuthLoading(),
      const Authenticated(tUser),
    ],
  );
}
