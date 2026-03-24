import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/app_constants.dart';

class NavigationService {
  final PolylinePoints _polylinePoints = PolylinePoints(apiKey: AppConstants.googleMapsApiKey);

  Future<List<LatLng>> getPolylinePoints(LatLng origin, LatLng destination) async {
    List<LatLng> polylineCoordinates = [];
    
    PolylineResult result = await _polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(origin.latitude, origin.longitude),
        destination: PointLatLng(destination.latitude, destination.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    
    return polylineCoordinates;
  }
}
