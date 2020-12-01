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
    var userRiverlogsRef =
        _firestore.collection('/riverlogs').doc(newRiverLog.uid);
    var userRiverlogsObj = await userRiverlogsRef.get();
    if (userRiverlogsObj.exists) {
      // if already exists then we append to that
      var foundObject = UserRiverlogModel.fromFire(userRiverlogsObj);
      foundObject.logSummary.add(newRiverLog.toRiverlogShortModel());
      userRiverlogsRef.update({
        'logSummary': foundObject.logSummary.map((e) => e.toJson()).toList()
      });
    } else {
      // if not already exists this is the new collection
      List<RiverlogShortModel> newLogs = List<RiverlogShortModel>();
      newLogs.add(newRiverLog.toRiverlogShortModel());
      userRiverlogsRef
          .set({'logSummary': newLogs.map((e) => e.toJson()).toList()});
    }

    var riverlogsRef = _firestore
        .collection('/riverlogs')
        .doc(newRiverLog.uid)
        .collection('/logs');
    var userRiverLogsDocRef = riverlogsRef.doc(newRiverLog.id);
    var countTotalRuns = await riverlogsRef.get();
    var countRiverRuns = await riverlogsRef
        .where('river.id', isEqualTo: newRiverLog.river.id)
        .get();
    newRiverLog.totalRound = countTotalRuns.docs.length + 1;
    newRiverLog.riverRound = countRiverRuns.docs.length + 1;

    userRiverLogsDocRef.set(newRiverLog.toJson());

    // also update user experience
    var userRef = _firestore.collection('/users').doc(newRiverLog.uid);
    var userObj = await userRef.get();
    updateUserExperience(userObj, newRiverLog, userRef);
    await updateUserStat(userObj, newRiverLog, riverlogsRef, userRef);
    return newRiverLog.id;
  }

  void updateUserExperience(DocumentSnapshot userObj, RiverlogModel newRiverLog,
      DocumentReference userRef) {
    var foundUser = UserModel.fromFire(userObj);
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
  }

  Future updateUserStat(DocumentSnapshot userObj, RiverlogModel newRiverLog,
      CollectionReference userRiverLogsRef, DocumentReference userRef) async {
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
      var allUserRiverlogs = await userRiverLogsRef.get();
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
