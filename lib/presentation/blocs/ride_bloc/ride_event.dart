import 'package:equatable/equatable.dart';
import '../../../domain/entities/ride_entity.dart';

abstract class RideEvent extends Equatable {
  const RideEvent();

  @override
  List<Object> get props => [];
}

class RequestRideEvent extends RideEvent {
  final RideEntity ride;
  const RequestRideEvent(this.ride);

  @override
  List<Object> get props => [ride];
}

class AcceptRideEvent extends RideEvent {
  final String rideId;
  final String driverId;
  const AcceptRideEvent(this.rideId, this.driverId);

  @override
  List<Object> get props => [rideId, driverId];
}

class UpdateRideStatusEvent extends RideEvent {
  final String rideId;
  final RideStatus status;
  const UpdateRideStatusEvent(this.rideId, this.status);

  @override
  List<Object> get props => [rideId, status];
}

class WatchAvailableRidesEvent extends RideEvent {}

class WatchDriverRidesEvent extends RideEvent {
  final String driverId;
  const WatchDriverRidesEvent(this.driverId);

  @override
  List<Object> get props => [driverId];
}

class WatchActiveRideEvent extends RideEvent {
  final String rideId;
  const WatchActiveRideEvent(this.rideId);

  @override
  List<Object> get props => [rideId];
}

class RidesUpdatedEvent extends RideEvent {
  final List<RideEntity> rides;
  const RidesUpdatedEvent(this.rides);

  @override
  List<Object> get props => [rides];
}

class ActiveRideUpdatedEvent extends RideEvent {
  final RideEntity? ride;
  const ActiveRideUpdatedEvent(this.ride);

  @override
  List<Object> get props => [ride ?? 'null'];
}

class VerifyOtpEvent extends RideEvent {
  final String rideId;
  final String otp;
  const VerifyOtpEvent(this.rideId, this.otp);

  @override
  List<Object> get props => [rideId, otp];
}

class SubmitRatingEvent extends RideEvent {
  final String rideId;
  final double rating;
  final String comment;

  const SubmitRatingEvent({
    required this.rideId,
    required this.rating,
    required this.comment,
  });

  @override
  List<Object> get props => [rideId, rating, comment];
}
