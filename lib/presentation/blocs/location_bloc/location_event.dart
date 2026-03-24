import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object> get props => [];
}

class LoadLocationRequested extends LocationEvent {}

class LocationUpdated extends LocationEvent {
  final Position position;
  const LocationUpdated(this.position);

  @override
  List<Object> get props => [position];
}
