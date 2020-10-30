import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yvrkayakers/blocs/riverlog/index.dart';

class RiverlogProvider {
  static final _firestore = FirebaseFirestore.instance;

  Future<List<RiverlogModel>> getRiverLogByUser(String userId) async {
    var foundDoc = await _firestore.collection('/riverlogs').doc(userId).get();
    var riverLogs = new List<RiverlogModel>();
    if (foundDoc.data() != null) {
      foundDoc.data()['logs'].forEach((t) {
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
    _firestore.collection('/riverlogs').doc(newRiverLog.userId).update({
      'logs': FieldValue.arrayUnion([newRiverLog.toJson()])
    });
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
