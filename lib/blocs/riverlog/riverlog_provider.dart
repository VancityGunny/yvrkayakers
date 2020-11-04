import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yvrkayakers/blocs/riverlog/index.dart';

class RiverlogProvider {
  static final _firestore = FirebaseFirestore.instance;

  Future<List<RiverlogModel>> getRiverLogByUser(String userId) async {
    var foundDoc = await _firestore.collection('/riverlogs').doc(userId).get();
    var riverLogs = new List<RiverlogModel>();
    if (foundDoc.exists) {
      var foundRivers = await _firestore
          .collection('/riverlogs')
          .doc(userId)
          .collection('/logs')
          .get();

      foundRivers.docs.forEach((t) {
        riverLogs.add(RiverlogModel.fromFire(t));
      });
    }

    return riverLogs;
  }

  Future<RiverlogModel> getRiverLogById(String riverLogId) async {
    var foundDoc =
        await _firestore.collection('/riverlogs').doc(riverLogId).get();
    var foundRiverLog = RiverlogModel.fromFire(foundDoc);
    return foundRiverLog;
  }

  Future<String> addRiverLog(RiverlogModel newRiverLog) async {
    var newRiverLogs =
        _firestore.collection('/riverlogs').doc(newRiverLog.userId);
    var newUserRiverLogs = newRiverLogs.collection('/logs').doc(newRiverLog.id);
    newUserRiverLogs.set(newRiverLog.toJson());
    return newRiverLog.id;
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
