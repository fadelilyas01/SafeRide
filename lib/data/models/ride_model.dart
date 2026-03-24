import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/ride_entity.dart';

class RideModel extends RideEntity {
  const RideModel({
    required super.id,
    required super.passengerId,
    super.driverId,
    required super.pickupLocation,
    required super.destinationLocation,
    required super.pickupAddress,
    required super.destinationAddress,
    required super.scheduledTime,
    required super.estimatedPrice,
    required super.status,
    super.otp,
    super.isWomenSafe = false,
    super.driverName,
    super.driverPhoto,
    super.vehicleInfo,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['id'] as String,
      passengerId: json['passengerId'] as String,
      driverId: json['driverId'] as String?,
      pickupLocation: LatLng(
        (json['pickupLat'] as num).toDouble(),
        (json['pickupLng'] as num).toDouble(),
      ),
      destinationLocation: LatLng(
        (json['destinationLat'] as num).toDouble(),
        (json['destinationLng'] as num).toDouble(),
      ),
      pickupAddress: json['pickupAddress'] as String,
      destinationAddress: json['destinationAddress'] as String,
      // Handle both Firestore Timestamp and ISO string from NestJS
      scheduledTime: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : json['scheduledTime'] is Timestamp
              ? (json['scheduledTime'] as Timestamp).toDate()
              : DateTime.now(),
      estimatedPrice: (json['estimatedPrice'] as num).toDouble(),
      status: RideStatus.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == (json['status'] as String).toUpperCase(),
        orElse: () => RideStatus.pending,
      ),
      otp: json['otp'] as String?,
      isWomenSafe: json['isWomenSafe'] as bool? ?? false,
      driverName: json['driver'] != null ? json['driver']['name'] as String? : json['driverName'] as String?,
      driverPhoto: json['driverPhoto'] as String?,
      vehicleInfo: json['vehicleInfo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passengerId': passengerId,
      'driverId': driverId,
      'pickupLat': pickupLocation.latitude,
      'pickupLng': pickupLocation.longitude,
      'destinationLat': destinationLocation.latitude,
      'destinationLng': destinationLocation.longitude,
      'pickupAddress': pickupAddress,
      'destinationAddress': destinationAddress,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'estimatedPrice': estimatedPrice,
      'status': status.toString().split('.').last,
      'otp': otp,
      'isWomenSafe': isWomenSafe,
      'driverName': driverName,
      'driverPhoto': driverPhoto,
      'vehicleInfo': vehicleInfo,
    };
  }
}
