import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:saferide/domain/entities/ride_entity.dart';
import 'package:saferide/domain/repositories/ride_repository.dart';
import 'package:saferide/presentation/blocs/ride_bloc/ride_bloc.dart';
import 'package:saferide/presentation/blocs/ride_bloc/ride_event.dart';
import 'package:saferide/presentation/blocs/ride_bloc/ride_state.dart';

// Mocktail Mock
class MockRideRepository extends Mock implements RideRepository {}

class FakeRideEntity extends Fake implements RideEntity {}

void main() {
  late RideBloc rideBloc;
  late MockRideRepository mockRideRepository;
  late StreamController<List<RideEntity>> ridesStreamController;
  late StreamController<RideEntity?> activeRideStreamController;

  setUpAll(() {
    registerFallbackValue(FakeRideEntity());
  });

  setUp(() {
    mockRideRepository = MockRideRepository();
    ridesStreamController = StreamController<List<RideEntity>>();
    activeRideStreamController = StreamController<RideEntity?>();

    rideBloc = RideBloc(rideRepository: mockRideRepository);
  });

  tearDown(() {
    ridesStreamController.close();
    activeRideStreamController.close();
    rideBloc.close();
  });

  final tRide = RideEntity(
    id: '1',
    passengerId: 'p1',
    pickupAddress: 'Start',
    destinationAddress: 'End',
    pickupLocation: const LatLng(0, 0),
    destinationLocation: const LatLng(1, 1),
    status: RideStatus.pending,
    estimatedPrice: 10.0,
    scheduledTime: DateTime.now(),
  );

  test('initial state should be RideInitial', () {
    expect(rideBloc.state, RideInitial());
  });

  blocTest<RideBloc, RideState>(
    'emits [RideLoading, RideRequestSuccess] when RequestRideEvent is successful',
    build: () {
      when(
        () => mockRideRepository.requestRide(any()),
      ).thenAnswer((_) async => Right(tRide));
      return rideBloc;
    },
    act: (bloc) => bloc.add(RequestRideEvent(tRide)),
    expect: () => [RideLoading(), RideRequestSuccess(tRide)],
  );

  blocTest<RideBloc, RideState>(
    'emits [AvailableRidesLoaded] when rides are updated via stream',
    build: () {
      when(
        () => mockRideRepository.getAvailableRides(),
      ).thenAnswer((_) => ridesStreamController.stream);
      return rideBloc;
    },
    act: (bloc) {
      bloc.add(WatchAvailableRidesEvent());
      ridesStreamController.add([tRide]);
    },
    expect: () => [
      AvailableRidesLoaded([tRide]),
    ],
  );

  blocTest<RideBloc, RideState>(
    'emits [RideActive] when active ride is updated via stream',
    build: () {
      when(
        () => mockRideRepository.getActiveRideStream(any()),
      ).thenAnswer((_) => activeRideStreamController.stream);
      return rideBloc;
    },
    act: (bloc) {
      bloc.add(const WatchActiveRideEvent('1'));
      activeRideStreamController.add(tRide);
    },
    expect: () => [RideActive(tRide)],
  );
}
