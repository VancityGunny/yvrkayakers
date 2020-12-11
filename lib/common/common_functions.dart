import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:hashids2/hashids2.dart';
import 'package:location/location.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';
import 'package:yvrkayakers/blocs/riverlog/index.dart';
import 'package:yvrkayakers/blocs/user/user_model.dart';
import 'package:yvrkayakers/common/myconstants.dart';

import 'package:flutter/material.dart';

class CommonFunctions {
  static String getHashtag(
      {RiverbetaShortModel river,
      RiverlogModel riverlog,
      UserShortModel user}) {
    //get hashtage for each type of object
    if (river != null) {
      return MyConstants.hashtagRiverPrefix +
          MyConstants.hashtagDelimiter +
          river.riverName.replaceAll(" ", "");
    }
    if (riverlog != null) {
      final hashids = HashIds(
        salt: 'YVRKayakers',
        minHashLength: 5,
        alphabet: 'abcdefghijklmnopqrstuvwxyz1234567890',
      );
      return MyConstants.hashtagRiverPrefix +
          MyConstants.hashtagDelimiter +
          riverlog.uid +
          MyConstants.hashtagDelimiter +
          hashids.encode(riverlog.totalRound);
    }
    if (user != null) {
      return MyConstants.hashtagUserPrefix +
          MyConstants.hashtagDelimiter +
          user.userName;
    }
  }

  static MaterialColor translateRiverDifficultyColor(double riverDifficulty) {
    if (riverDifficulty > 4.5) {
      return Colors.red;
    } else if (riverDifficulty > 3.5) {
      return Colors.orange;
    } else if (riverDifficulty > 2.5) {
      return Colors.green;
    }
    return Colors.blue; //default return nothing
  }

  static double getRiverDifficultyFromLabel(String difficultyLabel) {
    switch (difficultyLabel) {
      case "II":
        return 2.0;
        break;
      case "II+":
        return 2.25;
        break;
      case "III-":
        return 2.75;
        break;
      case "III":
        return 3.0;
        break;
      case "III+":
        return 3.25;
        break;
      case "IV-":
        return 3.75;
        break;
      case "IV":
        return 4.0;
        break;
      case "IV+":
        return 4.25;
        break;
      case "V":
        return 5.0;
        break;
    }
  }

  static String translateRiverDifficulty(double riverDifficulty) {
    if (riverDifficulty == null) return '';
    switch ((riverDifficulty * 100).round()) {
      case 200:
        return 'II';
        break;
      case 225:
        return 'II+';
        break;
      case 275:
        return 'III-';
        break;
      case 300:
        return 'III';
        break;
      case 325:
        return 'III+';
        break;
      case 375:
        return 'IV-';
        break;
      case 400:
        return 'IV';
        break;
      case 425:
        return 'IV+';
        break;
      case 500:
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

  static String formatOrdinalNumber(int number) {
    if (number == 11 || number == 12 || number == 13) {
      return number.toString() + "th";
    }
    switch (number % 10) {
      case 1:
        return number.toString() + "st";
        break;
      case 2:
        return number.toString() + "nd";
        break;
      case 3:
        return number.toString() + "rd";
        break;
      default:
        return number.toString() + "th";
        break;
    }
  }

  static String formatPostDateForDisplay(DateTime postedDate) {
    var timeElapsed = DateTime.now().difference(postedDate);
    if (timeElapsed.inDays < 1) {
      if (timeElapsed.inHours < 1) {
        if (timeElapsed.inMinutes < 1) {
          return "just now";
        } else {
          return timeElapsed.inMinutes.toString() + ' minute(s) ago';
        }
      } else {
        return timeElapsed.inHours.toString() + ' hour(s) ago';
      }
    } else {
      return timeElapsed.inDays.toString() + ' day(s) ago';
    }
  }

  static bool isAlphaNumeric(String testString) {
    final validCharacters = RegExp(r'^[a-zA-Z0-9]+$');
    return validCharacters.hasMatch(testString);
  }

  static String formatDateForDisplay(DateTime postedDate) {
    var timeElapsed = DateTime.now().difference(postedDate);
    if (timeElapsed.inDays < 1) {
      return "today";
    } else {
      return timeElapsed.inDays.toString() + ' day(s) ago';
    }
  }
}
