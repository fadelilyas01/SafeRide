enum RideStatus {
  pending,
  accepted,
  arrived,
  inProgress,
  completed,
  cancelled
}

class RideModel {
  final String? id;
  final String riderId;
  final String? driverId;
  final String pickupAddress;
  final double pickupLat;
  final double pickupLng;
  final String dropoffAddress;
  final double dropoffLat;
  final double dropoffLng;
  final RideStatus status;
  final double price;
  final String? otpCode;
  final DateTime? createdAt;

  RideModel({
    this.id,
    required this.riderId,
    this.driverId,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffAddress,
    required this.dropoffLat,
    required this.dropoffLng,
    this.status = RideStatus.pending,
    required this.price,
    this.otpCode,
    this.createdAt,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['id'],
      riderId: json['rider_id'],
      driverId: json['driver_id'],
      pickupAddress: json['pickup_address'],
      pickupLat: (json['pickup_lat'] as num).toDouble(),
      pickupLng: (json['pickup_lng'] as num).toDouble(),
      dropoffAddress: json['dropoff_address'],
      dropoffLat: (json['dropoff_lat'] as num).toDouble(),
      dropoffLng: (json['dropoff_lng'] as num).toDouble(),
      status: RideStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RideStatus.pending,
      ),
      price: (json['price'] as num).toDouble(),
      otpCode: json['otp_code'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'rider_id': riderId,
      if (driverId != null) 'driver_id': driverId,
      'pickup_address': pickupAddress,
      'pickup_lat': pickupLat,
      'pickup_lng': pickupLng,
      'dropoff_address': dropoffAddress,
      'dropoff_lat': dropoffLat,
      'dropoff_lng': dropoffLng,
      'status': status.name,
      'price': price,
      if (otpCode != null) 'otp_code': otpCode,
    };
  }
}
