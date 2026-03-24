import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum RideStatus { pending, accepted, onWay, started, completed, cancelled }

class RideEntity extends Equatable {
  final String id;
  final String passengerId;
  final String? driverId;
  final LatLng pickupLocation;
  final LatLng destinationLocation;
  final String pickupAddress;
  final String destinationAddress;
  final DateTime scheduledTime;
  final double estimatedPrice;
  final RideStatus status;
  final String? otp;
  final bool isWomenSafe;
  final String? driverName;
  final String? driverPhoto;
  final String? vehicleInfo;

  const RideEntity({
    required this.id,
    required this.passengerId,
    this.driverId,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.scheduledTime,
    required this.estimatedPrice,
    required this.status,
    this.otp,
    this.isWomenSafe = false,
    this.driverName,
    this.driverPhoto,
    this.vehicleInfo,
  });

  @override
  List<Object?> get props => [
        id,
        passengerId,
        driverId,
        pickupLocation,
        destinationLocation,
        pickupAddress,
        destinationAddress,
        scheduledTime,
        estimatedPrice,
        status,
        otp,
        isWomenSafe,
        driverName,
        driverPhoto,
        vehicleInfo,
      ];
}
