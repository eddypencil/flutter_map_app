import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_project2/cubits/locationCubit.dart';
import 'package:map_project2/cubits/markerCubit.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MarkersCubit(),
        ),
        BlocProvider(
          create: (context) => LocationCubit(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          bottomSheetTheme:
              const BottomSheetThemeData(backgroundColor: Color(0xffE5E7EB)),
        ),
        home: const MapScreen(),
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    context.read<LocationCubit>().startTrackingLocation();

    context.read<MarkersCubit>().loadMarkersFromDatabase();
  }

  @override
  void dispose() {
    context.read<LocationCubit>().stopTrackingLocation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<LocationCubit, LocationState>(
        builder: (context, locationState) {
          if (locationState is LocationLoaded) {
            Future.delayed(const Duration(milliseconds: 200), () {
              _mapController.move(
                LatLng(
                  locationState.position.latitude,
                  locationState.position.longitude,
                ),
                16.2, // Zoom level
              );
            });

            return BlocBuilder<MarkersCubit, MarkersState>(
              builder: (context, markersState) {
                List<Marker> markers = [];

                if (markersState is Loadmarkers) {
                  markers = markersState.markersList.map((markerData) {
                    return Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(
                          markerData.marker.latitude,
                          markerData.marker
                              .longitude), // Access directly if available
                      child: IconButton(
                        icon: Icon(
                          Icons.location_on,
                          color: Color(0xffFF3D00),
                          size: MediaQuery.of(context).size.width * 0.1,
                        ),
                        onPressed: () {
                          showMarkerDetailsBottomSheet(
                              context,
                              markerData.title,
                              markerData.description,
                              markerData.id);
                        },
                      ),
                    );
                  }).toList();
                }

                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    onTap: (tapPosition, point) {
                      _showAddMarkerBottomSheet(context, point);
                    },
                    minZoom: 4.0,
                    maxZoom: 18.0,
                    initialCenter: LatLng(locationState.position.latitude,
                        locationState.position.longitude),
                    initialZoom: 16.2,
                    backgroundColor: const Color(0xffE5E7EB),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(
                            locationState.position.latitude,
                            locationState.position.longitude,
                          ),
                          child: Container(
                            width: MediaQuery.of(context).size.width *
                                0.1, // Size of the circle
                            height: MediaQuery.of(context).size.width * 0.1,
                            decoration: BoxDecoration(
                              color: Color(0xff00BFFF), // Circle color
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white, // Border color
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                        ...markers,
                      ],
                    ),
                  ],
                );
              },
            );
          } else if (locationState is LocationError) {
            return Center(child: Text(locationState.errorMessage));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              double currentZoom = _mapController.camera.zoom;
              if (currentZoom > 4.0) {
                _mapController.move(
                  _mapController.camera.center,
                  currentZoom - 2.0,
                );
              }
            },
            child: Icon(
              Icons.remove,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(4, 4),
                  blurRadius: 8,
                )
              ],
            ),
            backgroundColor: Color(0xffE5E7EB),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            elevation: 8,
            onPressed: () {
              double currentZoom = _mapController.camera.zoom;
              if (currentZoom < 18.0) {
                _mapController.move(
                  _mapController.camera.center,
                  currentZoom + 2.0,
                );
              }
            },
            child: Icon(
              Icons.add,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(4, 4),
                  blurRadius: 8,
                )
              ],
            ),
            backgroundColor: Color(0xffE5E7EB),
          ),
        ],
      ),
    );
  }

  void _showAddMarkerBottomSheet(BuildContext context, LatLng point) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Add Marker",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text("Do you want to add a marker at this location?"),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Marker Title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xff00BFFF), width: 2),
                  ),
                  prefixIcon: const Icon(Icons.title),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.description),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 6,
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "  Cancel  ",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 6,
                      backgroundColor: Color(0xff00BFFF),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      final String title = titleController.text.trim();
                      final String description =
                          descriptionController.text.trim();
                      BlocProvider.of<MarkersCubit>(context)
                          .addMarker(point, title, description);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Add Marker",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 12,
              )
            ],
          ),
        );
      },
    );
  }

  void showMarkerDetailsBottomSheet(
      BuildContext context, String title, String description, String id) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () {
                        BlocProvider.of<MarkersCubit>(context).removeMarker(id);
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        FontAwesomeIcons.trash,
                        color: Colors.redAccent,
                      ))
                ],
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Close",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
