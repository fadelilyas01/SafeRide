import 'package:equatable/equatable.dart';
import '../../../domain/entities/ride_entity.dart';

abstract class RideState extends Equatable {
  const RideState();
  
  @override
  List<Object?> get props => [runtimeType];
}

class RideInitial extends RideState {}

class RideLoading extends RideState {}

class RideRequestSuccess extends RideState {
  final RideEntity ride;
  const RideRequestSuccess(this.ride);

  @override
  List<Object?> get props => [ride];
}

class RideActive extends RideState {
  final RideEntity ride;
  const RideActive(this.ride);

  @override
  List<Object?> get props => [ride];
}

class AvailableRidesLoaded extends RideState {
  final List<RideEntity> rides;
  const AvailableRidesLoaded(this.rides);

  @override
  List<Object?> get props => [runtimeType, rides];
}

class RideError extends RideState {
  final String message;
  const RideError(this.message);

  @override
  List<Object?> get props => [runtimeType, message];
}
