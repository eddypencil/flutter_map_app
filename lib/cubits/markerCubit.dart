



import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:latlong2/latlong.dart';
import 'package:map_project2/models/location_marker.dart';
import 'package:map_project2/services/sqlite/sqflite.dart';


import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

abstract class MarkersState {}

class IsLoadingmarkers extends MarkersState {}

class Loadmarkers extends MarkersState {
  final List<LocationMarker> markersList;

  Loadmarkers(this.markersList);
}


class MarkersCubit extends Cubit<MarkersState> {
  MarkersCubit() : super(IsLoadingmarkers());

  final List<LocationMarker> markersList = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  

  void setMarkersList(List<LocationMarker> markers) {
    log('Current marker IDs: ${markersList.map((e) => e.id.toString()).toList()}');
    markersList.clear();
    markersList.addAll(markers);
    emit(Loadmarkers(List.from(markersList))); 
  }

 
  void addMarker(LatLng point, String title, String description) async {
  LocationMarker newMarker = LocationMarker(
    title: title,
    marker: point,
    description: description,
  );

  
  markersList.add(newMarker);
  await _databaseHelper.insertMarker(newMarker);
  emit(Loadmarkers(List.from(markersList)));
}



  void loadMarkersFromDatabase() async {
  try {
    final markers = await _databaseHelper.getMarkers();
    setMarkersList(markers);
  } catch (e) {
    print("Error loading markers from database: $e");
  }
}

  
  void removeMarker(String id) async {
  try {
    
    markersList.removeWhere((marker) => marker.id == id);
    await _databaseHelper.removeMarker(id);
    emit(Loadmarkers(List.from(markersList)));
  } catch (e) {
    log("Error removing marker: $e");
  }
}

}
