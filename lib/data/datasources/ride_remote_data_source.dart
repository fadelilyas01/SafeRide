import 'dart:async';
import '../models/ride_model.dart';
import '../../domain/entities/ride_entity.dart';
import 'backend_client.dart';
import 'socket_client.dart';

abstract class RideRemoteDataSource {
  Future<RideModel> requestRide(RideModel ride);
  Future<void> updateRideStatus(String rideId, RideStatus status, {String? driverId});
  Future<void> verifyOtpAndStartRide(String rideId, String otp);
  Stream<List<RideModel>> getPassengerRides(String passengerId);
  Stream<List<RideModel>> getDriverRides(String driverId);
  Stream<List<RideModel>> getAvailableRides();
  Stream<RideModel?> getActiveRideStream(String rideId);
  Future<void> submitRating(String rideId, double rating, String comment);
}

class RideRemoteDataSourceImpl implements RideRemoteDataSource {
  final BackendClient _client = BackendClient();
  final SocketClient _socket = SocketClient();

  @override
  Future<RideModel> requestRide(RideModel ride) async {
    final res = await _client.post('/rides', {
      'passengerId': ride.passengerId,
      'pickupLat': ride.pickupLocation.latitude,
      'pickupLng': ride.pickupLocation.longitude,
      'pickupAddress': ride.pickupAddress,
      'destinationLat': ride.destinationLocation.latitude,
      'destinationLng': ride.destinationLocation.longitude,
      'destinationAddress': ride.destinationAddress,
      'estimatedPrice': ride.estimatedPrice,
      'isWomenSafe': ride.isWomenSafe,
    });
    return RideModel.fromJson(res);
  }

  @override
  Future<void> updateRideStatus(String rideId, RideStatus status, {String? driverId}) async {
    await _client.patch('/rides/$rideId/status', {
      'status': status.name.toUpperCase(),
      'driverId': driverId,
    });
  }

  @override
  Future<void> verifyOtpAndStartRide(String rideId, String otp) async {
    final ride = await _client.get('/rides/$rideId');
    if (ride['otp'] != otp) throw Exception('OTP invalide');
    await updateRideStatus(rideId, RideStatus.started);
  }

  @override
  Stream<List<RideModel>> getPassengerRides(String passengerId) async* {
    // Note: Normalement filtré par le backend
    final List<dynamic> res = await _client.get('/rides/active');
    yield res.map((item) => RideModel.fromJson(item)).toList();
  }

  @override
  Stream<List<RideModel>> getDriverRides(String driverId) async* {
    final List<dynamic> res = await _client.get('/rides/active');
    yield res.map((item) => RideModel.fromJson(item)).toList();
  }

  @override
  Stream<List<RideModel>> getAvailableRides() async* {
    // 1. D'abord on retourne la liste actuelle via HTTP
    final List<dynamic> res = await _client.get('/rides/active');
    final initialRides = res
        .where((item) => item['status'] == 'PENDING')
        .map((item) => RideModel.fromJson(item))
        .toList();
    yield initialRides;
    
    // 2. Ensuite on s'abonne au WebSocket pour les nouveaux trajets
    await for (final event in _socket.rideRequestedStream) {
      // Pour une vraie app, on cumulerait l'état. Pour la démo, on refetch ou on ajoute au flux
      final List<dynamic> updatedRes = await _client.get('/rides/active');
      yield updatedRes
          .where((item) => item['status'] == 'PENDING')
          .map((item) => RideModel.fromJson(item))
          .toList();
    }
  }

  @override
  Stream<RideModel?> getActiveRideStream(String rideId) async* {
    // 1. Fetch initial state
    try {
      final res = await _client.get('/rides/$rideId');
      yield RideModel.fromJson(res);
    } catch (_) {
      yield null;
    }

    // 2. Listen for socket updates
    _socket.listenToRideStatus(rideId);
    await for (final event in _socket.rideStatusStream) {
      try {
         // Le payload event est probablement le ride complet
         yield RideModel.fromJson(event);
      } catch (_) {
         yield null;
      }
    }
  }

  @override
  Future<void> submitRating(String rideId, double rating, String comment) async {
    // Pas encore implémenté sur le backend, simulation
  }
}
