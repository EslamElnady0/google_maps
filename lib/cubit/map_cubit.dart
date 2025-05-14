import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import '../repo/map_repo.dart';

part 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  final MapRepo _mapRepo;
  StreamSubscription<LocationData>? _locationSubscription;

  MapCubit(this._mapRepo) : super(const MapState.initial());

  void init() async {
    emit(const MapState.loading());
    try {
      final location = await _mapRepo.getCurrentLocation();
      final marker = Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(location.latitude!, location.longitude!),
        child: const Icon(Icons.my_location, color: Colors.blue, size: 40.0),
      );
      emit(MapState.loaded(
        currentLocation: LatLng(location.latitude!, location.longitude!),
        markers: [marker],
        routePoints: [],
      ));

      // Listen to location changes
      _locationSubscription =
          _mapRepo.onLocationChanged().listen((newLocation) {
        final updatedMarker = Marker(
          width: 80.0,
          height: 80.0,
          point: LatLng(newLocation.latitude!, newLocation.longitude!),
          child: const Icon(Icons.my_location, color: Colors.blue, size: 40.0),
        );
        emit(state.copyWith(
          currentLocation:
              LatLng(newLocation.latitude!, newLocation.longitude!),
          markers: [
            updatedMarker,
            if (state.markers.length > 1)
              state.markers[1], // Keep destination marker
          ],
        ));
      });
    } catch (e) {
      emit(MapState.error(e.toString()));
    }
  }

  void addDestination(LatLng destination) async {
    if (state.currentLocation == null) return;

    emit(state.copyWith(isLoading: true));
    try {
      final routePoints =
          await _mapRepo.getRoute(state.currentLocation!, destination);
      final destinationMarker = Marker(
        width: 80.0,
        height: 80.0,
        point: destination,
        child: const Icon(Icons.location_on, color: Colors.red, size: 40.0),
      );
      emit(state.copyWith(
        markers: [
          state.markers[0],
          destinationMarker
        ], // Keep current location marker
        routePoints: routePoints,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  void reset() {
    if (state.currentLocation == null) return;
    final marker = Marker(
      width: 80.0,
      height: 80.0,
      point: state.currentLocation!,
      child: const Icon(Icons.my_location, color: Colors.blue, size: 40.0),
    );
    emit(state.copyWith(
      markers: [marker],
      routePoints: [],
      error: null,
    ));
  }

  void recenter() {
    if (state.currentLocation != null) {
      emit(state.copyWith(recenter: true));
    }
  }

  void clearRecenter() {
    emit(state.copyWith(recenter: false));
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }
}
