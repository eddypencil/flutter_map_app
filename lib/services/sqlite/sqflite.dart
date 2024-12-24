import 'package:latlong2/latlong.dart';
import 'package:map_project2/models/location_marker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';



class DatabaseHelper {
  static Database? _database;

  
  Future<Database> get database async {
    if (_database != null) return _database!;

    
    _database = await _initDatabase();
    return _database!;
  }


  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'markers.db');

    
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }


  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE user_markers(
      id TEXT PRIMARY KEY,
      title TEXT,
      latitude REAL,
      longitude REAL,
      description TEXT
    )
    ''');
  }

 
  Future<int> insertMarker(LocationMarker marker) async {
    final db = await database;
    final markerMap = {
      'id': marker.id,
      'title': marker.title,
      'latitude': marker.marker.latitude,
      'longitude': marker.marker.longitude,
      'description': marker.description,
    };
    return await db.insert('user_markers', markerMap);
  }

  
  Future<List<LocationMarker>> getMarkers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user_markers');

    return List.generate(maps.length, (i) {
      return LocationMarker(
        title: maps[i]['title'],
        marker: LatLng(maps[i]['latitude'], maps[i]['longitude']),
        description: maps[i]['description'],
      );
    });
  }

  Future<int> removeMarker(String id) async {
    final db = await database;

    return await db.delete(
      'user_markers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}




