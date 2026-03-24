import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/ride_repository.dart';
import 'ride_event.dart';
import 'ride_state.dart';

class RideBloc extends Bloc<RideEvent, RideState> {
  final RideRepository _rideRepository;
  StreamSubscription? _ridesSubscription;
  StreamSubscription? _activeRideSubscription;

  RideBloc({required RideRepository rideRepository})
      : _rideRepository = rideRepository,
        super(RideInitial()) {
    on<RequestRideEvent>(_onRequestRide);
    on<AcceptRideEvent>(_onAcceptRide);
    on<UpdateRideStatusEvent>(_onUpdateRideStatus);
    on<WatchAvailableRidesEvent>(_onWatchAvailableRides);
    on<WatchActiveRideEvent>(_onWatchActiveRide);
    on<RidesUpdatedEvent>(_onRidesUpdated);
    on<ActiveRideUpdatedEvent>(_onActiveRideUpdated);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<WatchDriverRidesEvent>(_onWatchDriverRides);
    on<SubmitRatingEvent>(_onSubmitRating);
  }

  void _onWatchDriverRides(WatchDriverRidesEvent event, Emitter<RideState> emit) {
    _ridesSubscription?.cancel();
    _ridesSubscription = _rideRepository.getDriverRides(event.driverId).listen(
      (rides) => add(RidesUpdatedEvent(rides)),
    );
  }

  Future<void> _onVerifyOtp(VerifyOtpEvent event, Emitter<RideState> emit) async {
    emit(RideLoading());
    final result = await _rideRepository.verifyOtpAndStartRide(event.rideId, event.otp);
    result.fold(
      (failure) => emit(RideError(failure.message)),
      (_) => null, // Le statut sera mis à jour via le stream
    );
  }

  Future<void> _onRequestRide(RequestRideEvent event, Emitter<RideState> emit) async {
    emit(RideLoading());
    final result = await _rideRepository.requestRide(event.ride);
    result.fold(
      (failure) => emit(RideError(failure.message)),
      (ride) => emit(RideRequestSuccess(ride)),
    );
  }

  Future<void> _onAcceptRide(AcceptRideEvent event, Emitter<RideState> emit) async {
    emit(RideLoading());
    final result = await _rideRepository.acceptRide(event.rideId, event.driverId);
    result.fold(
      (failure) => emit(RideError(failure.message)),
      (_) => null, // Will be updated via stream
    );
  }

  Future<void> _onUpdateRideStatus(UpdateRideStatusEvent event, Emitter<RideState> emit) async {
    final result = await _rideRepository.updateRideStatus(event.rideId, event.status);
    result.fold(
      (failure) => emit(RideError(failure.message)),
      (_) => null,
    );
  }

  void _onWatchAvailableRides(WatchAvailableRidesEvent event, Emitter<RideState> emit) {
    _ridesSubscription?.cancel();
    _ridesSubscription = _rideRepository.getAvailableRides().listen(
      (rides) => add(RidesUpdatedEvent(rides)),
    );
  }

  void _onWatchActiveRide(WatchActiveRideEvent event, Emitter<RideState> emit) {
    _activeRideSubscription?.cancel();
    _activeRideSubscription = _rideRepository.getActiveRideStream(event.rideId).listen(
      (ride) => add(ActiveRideUpdatedEvent(ride)),
    );
  }

  void _onRidesUpdated(RidesUpdatedEvent event, Emitter<RideState> emit) {
    emit(AvailableRidesLoaded(event.rides));
  }

  void _onActiveRideUpdated(ActiveRideUpdatedEvent event, Emitter<RideState> emit) {
    if (event.ride != null) {
      emit(RideActive(event.ride!));
    } else {
      emit(RideInitial());
    }
  }

  Future<void> _onSubmitRating(SubmitRatingEvent event, Emitter<RideState> emit) async {
    final result = await _rideRepository.submitRating(event.rideId, event.rating, event.comment);
    result.fold(
      (failure) => emit(RideError(failure.message)),
      (_) => null,
    );
  }

  @override
  Future<void> close() {
    _ridesSubscription?.cancel();
    _activeRideSubscription?.cancel();
    return super.close();
  }
}
