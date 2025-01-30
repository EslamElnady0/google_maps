import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';

class LocationService {
  String orsApiKey = "5b3ce3597851110001cf6248b9608669b259480a99bcc69f2180c468";

  Future<void> getCurrentLocation({
    required void Function() setState,
    required List<Marker> markers,
    required LocationData? userLocation,
  }) async {
    var location = Location();
    try {
      var userLocation = await location.getLocation();
      setState();
      //var userLocation = ;
      print(userLocation);
    } catch (e) {
      userLocation = null;
      print(e);
    }
  }
}
