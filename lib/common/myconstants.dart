import 'package:flutter_native_config/flutter_native_config.dart';

class MyConstants {
  static List<double> RIVER_GRADES = [
    2.0,
    2.25,
    2.75,
    3.0,
    3.25,
    3.75,
    4.0,
    4.25,
    5.0
  ];

  static Future<String> googleApiKey() {
    return FlutterNativeConfig.getConfig<String>(
      android: 'com.google.android.geo.API_KEY',
      ios: 'CFBundleName',
    );
  }
}
