import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yvrkayakers/blocs/trip/trip_model.dart';

class TripProvider {
  static final _firestore = FirebaseFirestore.instance;
  Future<void> loadAsync(String token) async {
    /// write from keystore/keychain
    await Future.delayed(Duration(seconds: 2));
  }

  Future<void> saveAsync(String token) async {
    /// write from keystore/keychain
    await Future.delayed(Duration(seconds: 2));
  }

  void test(bool isError) {
    if (isError == true) {
      throw Exception('manual error');
    }
  }

  Future<String> addTrip(TripModel newTrip) async {
    var newTripRef = _firestore.collection('/trips').doc(newTrip.id);
    newTripRef.set(newTrip.toJson());
    return newTrip.id;
  }
}
