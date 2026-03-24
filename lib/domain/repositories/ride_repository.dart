import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/ride_entity.dart';

abstract class RideRepository {
  Future<Either<Failure, RideEntity>> requestRide(RideEntity ride);
  Future<Either<Failure, void>> cancelRide(String rideId);
  Future<Either<Failure, void>> acceptRide(String rideId, String driverId);
  Future<Either<Failure, void>> updateRideStatus(String rideId, RideStatus status);
  
  Future<Either<Failure, void>> verifyOtpAndStartRide(String rideId, String otp);
  
  Stream<List<RideEntity>> getPassengerRides(String passengerId);
  Stream<List<RideEntity>> getDriverRides(String driverId);
  Stream<List<RideEntity>> getAvailableRides(); // For drivers to see pending rides
  Stream<RideEntity?> getActiveRideStream(String rideId);
  Future<Either<Failure, void>> submitRating(String rideId, double rating, String comment);
}
