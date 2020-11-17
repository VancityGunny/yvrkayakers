import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
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
    List<UserExperienceModel> newExperiences = foundUser.experience;
    newExperiences
        .where((element) => element.riverGrade == newRiverLog.river.difficulty)
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
    UserStatModel userStatObj;

    if (userObj.data()['userStat'] == null) {
      //this is the first log so log this
      userStatObj = new UserStatModel(newRiverLog.river, newRiverLog.logDate,
          (newRiverLog.didSwim) ? 1 : 0, (newRiverLog.didRescue) ? 1 : 0);

      //wait for
    } else {
      userStatObj = UserStatModel.fromJson(userObj.data()['userStat']);
      //modify with new value
      userStatObj.lastWetness =
          (userStatObj.lastWetness.isBefore(newRiverLog.logDate))
              ? newRiverLog.logDate
              : userStatObj.lastWetness;
      userStatObj.swimCount = (newRiverLog.didSwim)
          ? userStatObj.swimCount + 1
          : userStatObj.swimCount;
      userStatObj.rescueCount = (newRiverLog.didRescue)
          ? userStatObj.rescueCount + 1
          : userStatObj.rescueCount;
      // check if favorite river still the same
      var allUserRiverlogs = await newRiverLogs.collection('/logs').get();
      var allUserRiverlogsObj =
          allUserRiverlogs.docs.map((e) => RiverlogModel.fromFire(e)).toList();

      var newGroupedData =
          groupBy(allUserRiverlogsObj, (RiverlogModel obj) => obj.river.id)
              .map((key, value) => MapEntry(value.first.river, value.length));

      var sortedKeys = newGroupedData.keys.toList(growable: false)
        ..sort((k1, k2) => newGroupedData[k1].compareTo(newGroupedData[k2]));
      LinkedHashMap sortedMap = new LinkedHashMap.fromIterable(sortedKeys,
          key: (k) => k, value: (k) => newGroupedData[k]);

      userStatObj.favoriteRiver = sortedKeys.last;
    }
    userRef.update({'userStat': userStatObj.toJson()});
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
