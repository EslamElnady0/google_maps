import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

class MapRepo {
  final Location _location;
  final String orsApiKey;

  MapRepo({required this.orsApiKey}) : _location = Location();

  Future<LocationData> getCurrentLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          throw Exception('Location service is disabled');
        }
      }

      PermissionStatus permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await _location.requestPermission();
        if (permission != PermissionStatus.granted) {
          throw Exception('Location permission denied');
        }
      }

      return await _location.getLocation();
    } catch (e) {
      throw Exception('Failed to get current location: $e');
    }
  }

  Stream<LocationData> onLocationChanged() {
    return _location.onLocationChanged;
  }

  Future<List<LatLng>> getRoute(LatLng start, LatLng destination) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openrouteservice.org/v2/directions/foot-walking?api_key=$orsApiKey&start=${start.longitude},${start.latitude}&end=${destination.longitude},${destination.latitude}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> coords =
            data['features'][0]['geometry']['coordinates'];
        return coords.map((coord) => LatLng(coord[1], coord[0])).toList();
      } else {
        throw Exception('Failed to fetch route: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get route: $e');
    }
  }
}
