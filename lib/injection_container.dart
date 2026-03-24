import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'presentation/blocs/auth_bloc/auth_bloc.dart';
import 'presentation/blocs/location_bloc/location_bloc.dart';
import 'presentation/blocs/ride_bloc/ride_bloc.dart';
import 'presentation/blocs/chat_bloc/chat_bloc.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/datasources/location_service.dart';
import 'data/datasources/ride_remote_data_source.dart';
import 'data/datasources/navigation_service.dart';
import 'data/datasources/notification_service.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/ride_repository_impl.dart';
import 'data/repositories/chat_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/ride_repository.dart';
import 'domain/repositories/chat_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<LocationService>(
    () => LocationServiceImpl(),
  );

  sl.registerLazySingleton<RideRemoteDataSource>(
    () => RideRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<NavigationService>(
    () => NavigationService(),
  );

  sl.registerLazySingleton<NotificationService>(
    () => NotificationService(),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<RideRepository>(
    () => RideRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(firestore: sl()),
  );

  // Features - Authentication
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  
  // Features - Location
  sl.registerFactory(() => LocationBloc(locationService: sl()));

  // Features - Ride
  sl.registerFactory(() => RideBloc(rideRepository: sl()));

  // Features - Chat
  sl.registerFactory(() => ChatBloc(chatRepository: sl()));
}
