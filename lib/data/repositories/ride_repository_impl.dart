import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/ride_entity.dart';
import '../../domain/repositories/ride_repository.dart';
import '../datasources/ride_remote_data_source.dart';
import '../models/ride_model.dart';

class RideRepositoryImpl implements RideRepository {
  final RideRemoteDataSource remoteDataSource;

  RideRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, RideEntity>> requestRide(RideEntity ride) async {
    try {
      final model = RideModel(
        id: ride.id,
        passengerId: ride.passengerId,
        pickupLocation: ride.pickupLocation,
        destinationLocation: ride.destinationLocation,
        pickupAddress: ride.pickupAddress,
        destinationAddress: ride.destinationAddress,
        scheduledTime: ride.scheduledTime,
        estimatedPrice: ride.estimatedPrice,
        status: ride.status,
      );
      final result = await remoteDataSource.requestRide(model);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> acceptRide(String rideId, String driverId) async {
    try {
      await remoteDataSource.updateRideStatus(rideId, RideStatus.accepted, driverId: driverId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelRide(String rideId) async {
    try {
      await remoteDataSource.updateRideStatus(rideId, RideStatus.cancelled);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateRideStatus(String rideId, RideStatus status) async {
    try {
      await remoteDataSource.updateRideStatus(rideId, status);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyOtpAndStartRide(String rideId, String otp) async {
    try {
      await remoteDataSource.verifyOtpAndStartRide(rideId, otp);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<RideEntity>> getPassengerRides(String passengerId) => remoteDataSource.getPassengerRides(passengerId);

  @override
  Stream<List<RideEntity>> getDriverRides(String driverId) => remoteDataSource.getDriverRides(driverId);

  @override
  Stream<List<RideEntity>> getAvailableRides() => remoteDataSource.getAvailableRides();

  @override
  Stream<RideEntity?> getActiveRideStream(String rideId) => remoteDataSource.getActiveRideStream(rideId);

  @override
  Future<Either<Failure, void>> submitRating(String rideId, double rating, String comment) async {
    try {
      await remoteDataSource.submitRating(rideId, rating, comment);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
