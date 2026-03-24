import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'backend_client.dart';

class SocketClient {
  static final SocketClient _instance = SocketClient._internal();
  late IO.Socket socket;
  
  final _rideRequestedController = StreamController<dynamic>.broadcast();
  final _rideAcceptedController = StreamController<dynamic>.broadcast();
  final _rideStatusController = StreamController<dynamic>.broadcast();

  factory SocketClient() {
    return _instance;
  }

  SocketClient._internal() {
    _initSocket();
  }

  void _initSocket() {
    socket = IO.io(BackendClient.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.onConnect((_) {
      print('Connected to Socket.IO Server');
    });

    socket.on('ride_requested', (data) {
      _rideRequestedController.add(data);
    });

    socket.onDisconnect((_) => print('Disconnected from Socket.IO Server'));
    
    // Auto-connect for now
    connect();
  }

  void connect() {
    if (!socket.connected) {
      socket.connect();
    }
  }

  void disconnect() {
    if (socket.connected) {
      socket.disconnect();
    }
  }

  Stream<dynamic> get rideRequestedStream => _rideRequestedController.stream;
  
  void listenToPassenger(String passengerId) {
    socket.off('ride_accepted_$passengerId');
    socket.on('ride_accepted_$passengerId', (data) {
      _rideAcceptedController.add(data);
    });
  }
  
  Stream<dynamic> get rideAcceptedStream => _rideAcceptedController.stream;
  
  void listenToRideStatus(String rideId) {
    socket.off('ride_status_$rideId');
    socket.on('ride_status_$rideId', (data) {
      _rideStatusController.add(data);
    });
  }

  Stream<dynamic> get rideStatusStream => _rideStatusController.stream;
}
