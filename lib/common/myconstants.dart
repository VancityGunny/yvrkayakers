import 'package:flutter_native_config/flutter_native_config.dart';

class MyConstants {
  //hashtag prefix to be use to identify our post in social media
  static String hashtagRiverPrefix = "YVRKR";
  static String hashtagLogPrefix = "YVRKL";
  static String hashtagUserPrefix = "YVRKU";
  static String hashtagDelimiter = "_";
  static const List<double> RIVER_GRADES = [
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
  static List<String> RIVER_GRADES_LABELS = [
    "II",
    "II+",
    "III-",
    "III",
    "III+",
    "IV-",
    "IV",
    "IV+",
    "V"
  ];

  static Future<String> googleApiKey() {
    return FlutterNativeConfig.getConfig<String>(
      android: 'com.google.android.geo.API_KEY',
      ios: 'CFBundleName',
    );
  }
}
