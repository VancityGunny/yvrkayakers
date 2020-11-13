import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yvrkayakers/blocs/riverlog/index.dart';
import 'package:yvrkayakers/blocs/user/user_model.dart';

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

    // also update user experience
    var userRef = _firestore.collection('/users').doc(newRiverLog.userId);
    var userObj = await userRef.get();
    var foundUser = UserModel.fromJson(userObj.data());
    var newExperiences = foundUser.experience;
    newExperiences
        .where((element) => element.riverGrade == newRiverLog.riverDifficulty)
        .forEach((element) {
      element.runCount = element.runCount + 1;
    });

    var userSkill = newExperiences
        .where((element) => element.runCount >= 5)
        .fold(
            2.0,
            (previousValue, element) => (element.riverGrade > previousValue)
                ? element.riverGrade
                : previousValue);
    var verifiedUserSkill = newExperiences
        .where((element) => element.verifiedRunCount >= 3)
        .fold(
            2.0,
            (previousValue, element) => (element.riverGrade > previousValue)
                ? element.riverGrade
                : previousValue);

    userRef.update({
      'experience': newExperiences.map((e) => e.toJson()).toList(),
      'userSkill': userSkill,
      'userSkillVerified': verifiedUserSkill
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
