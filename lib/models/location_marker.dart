import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

class LocationMarker{
  String id;
  String title;
  LatLng marker;
  String description;


  LocationMarker({required this.title, required this.marker, required this.description}) : id = const Uuid().v4();


}