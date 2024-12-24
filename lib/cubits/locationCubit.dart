import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/widgets.dart';

abstract class LocationState {}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final Position position;
  LocationLoaded(this.position);
}

class LocationError extends LocationState {
  final String errorMessage;
  LocationError(this.errorMessage);
}

class LocationCubit extends Cubit<LocationState> {
  late StreamSubscription<Position> _positionStream;
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  LocationCubit() : super(LocationInitial());

  // Start tracking location
  Future<void> startTrackingLocation() async {
    emit(LocationLoading());

    // Check if the location permission is granted
    LocationPermission permission = await Geolocator.checkPermission();

    // If permission is denied, request permission
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    // If permission is granted, start tracking location
    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position position) {
        if (position != null) {
          
          Future.delayed(Duration.zero, () {
            
            emit(LocationLoaded(position));
          });
        }
      }, onError: (error) {
        emit(LocationError("Error while fetching location: $error"));
      });
    } else {
      emit(LocationError("Location permission is not granted."));
    }
  }

  // Stop listening when the app is disposed
  void stopTrackingLocation() {
    _positionStream.cancel();
  }
}