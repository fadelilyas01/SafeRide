import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/location_service.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationService _locationService;
  StreamSubscription? _locationSubscription;

  LocationBloc({required LocationService locationService})
      : _locationService = locationService,
        super(LocationInitial()) {
    on<LoadLocationRequested>(_onLoadLocationRequested);
    on<LocationUpdated>(_onLocationUpdated);
  }

  Future<void> _onLoadLocationRequested(LoadLocationRequested event, Emitter<LocationState> emit) async {
    emit(LocationLoading());
    try {
      final hasPermission = await _locationService.checkPermissions();
      if (!hasPermission) {
        final requested = await _locationService.requestPermissions();
        if (!requested) {
          emit(LocationPermissionDenied());
          return;
        }
      }

      final position = await _locationService.getCurrentPosition();
      emit(LocationLoaded(position));

      _locationSubscription?.cancel();
      _locationSubscription = _locationService.getPositionStream().listen(
        (position) => add(LocationUpdated(position)),
      );
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  void _onLocationUpdated(LocationUpdated event, Emitter<LocationState> emit) {
    emit(LocationLoaded(event.position));
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }
}
