import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';

class RiverbetaProvider {
  static final _firestore = FirebaseFirestore.instance;
  static final Geoflutterfire geo = Geoflutterfire();

  Future<List<RiverbetaModel>> getNearbyRivers(
      GeoFirePoint center, double distance) async {
    var collectionReference = _firestore.collection('riverbetas');
    double radius = distance; //50; //kilometer
    String field = 'putInLocation';
    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: collectionReference)
        .within(center: center, radius: radius, field: field);
    return stream.first.then((documentList) => documentList
        .map<RiverbetaModel>((e) => RiverbetaModel.fromFire(e))
        .toList());
  }

  Future<RiverbetaModel> getRiverById(String riverId) async {
    var foundDoc =
        await _firestore.collection('/riverbetas').doc(riverId).get();
    var foundRiver = RiverbetaModel.fromFire(foundDoc);
    return foundRiver;
  }

  Future<String> addRiver(RiverbetaModel newRiver) async {
    var newRiverObj = _firestore.collection('/riverbetas').doc(newRiver.id);
    newRiverObj.set(newRiver.toJson());
    return newRiverObj.id;
  }

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
}
