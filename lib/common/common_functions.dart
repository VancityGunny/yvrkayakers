import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';

class CommonFunctions {
  static String translateRiverDifficulty(double riverDifficulty) {
    if (riverDifficulty == null) return '';
    switch ((riverDifficulty * 10).round()) {
      case 20:
        return 'II';
        break;
      case 25:
        return 'II+';
        break;
      case 30:
        return 'III';
        break;
      case 35:
        return 'III+';
        break;
      case 40:
        return 'IV';
        break;
      case 45:
        return 'IV+';
        break;
      case 50:
        return 'V';
        break;
    }
    return ''; //default return nothing
  }

  static Future<GeoFirePoint> getCurrentLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return GeoFirePoint(49.246292, -123.116226);
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return GeoFirePoint(49.246292, -123.116226);
      }
    }

    _locationData = await location.getLocation();
    return GeoFirePoint(_locationData.latitude, _locationData.longitude);
  }
}
