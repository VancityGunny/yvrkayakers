import 'package:equatable/equatable.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserShortModel extends Equatable {
  final String id;
  final String displayName;
  final String photoUrl;

  UserShortModel(this.id, this.displayName, this.photoUrl);

  @override
  // TODO: implement props
  List<Object> get props => [id, displayName, photoUrl];

  factory UserShortModel.fromJson(Map<dynamic, dynamic> json) {
    return UserShortModel(json['id'] as String, json['displayName'] as String,
        json['photoUrl'] as String);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = this.id;
    data['displayName'] = this.displayName;
    data['photoUrl'] = this.photoUrl;
    return data;
  }
}

class UserExperienceModel extends Equatable {
  final double riverGrade;
  int runCount;
  int verifiedRunCount;

  UserExperienceModel(this.riverGrade, this.runCount, this.verifiedRunCount);

  @override
  // TODO: implement props
  List<Object> get props => [riverGrade, runCount, verifiedRunCount];

  factory UserExperienceModel.fromJson(Map<dynamic, dynamic> json) {
    return UserExperienceModel(json['riverGrade'] as double,
        json['runCount'] as int, json['verifiedRunCount'] as int);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['riverGrade'] = this.riverGrade;
    data['runCount'] = this.runCount;
    data['verifiedRunCount'] = this.verifiedRunCount;
    return data;
  }
}

class UserStatModel extends Equatable {
  RiverbetaShortModel favoriteRiver;
  DateTime lastWetness;
  int swimCount;
  int rescueCount;
  UserStatModel(
      this.favoriteRiver, this.lastWetness, this.swimCount, this.rescueCount);

  @override
  // TODO: implement props
  List<Object> get props =>
      [favoriteRiver, lastWetness, swimCount, rescueCount];

  factory UserStatModel.fromJson(Map<dynamic, dynamic> json) {
    if (json == null) {
      return null;
    }
    return UserStatModel(
        RiverbetaShortModel.fromJson(json['favoriteRiver']),
        DateTime.parse(json['lastWetness']),
        json['swimCount'],
        json['rescueCount']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['favoriteRiver'] = this.favoriteRiver.toJson();
    data['lastWetness'] = this.lastWetness.toIso8601String();
    data['swimCount'] = this.swimCount;
    data['rescueCount'] = this.rescueCount;
    return data;
  }
}

class UserModel extends UserShortModel {
  final String uid;
  final String email;
  final String phone;
  final List<UserExperienceModel> experience;
  final double userSkill;
  final double userSkillVerified;
  final UserStatModel userStat;

  UserModel(id, this.uid, this.email, displayName, this.phone, photoUrl,
      this.experience, this.userSkill, this.userSkillVerified, this.userStat)
      : super(id, displayName, photoUrl);

  @override
  List<Object> get props => [
        id,
        uid,
        email,
        displayName,
        phone,
        photoUrl,
        experience,
        userSkill,
        userSkillVerified,
        userStat
      ];

  factory UserModel.fromFire(DocumentSnapshot doc) {
    var json = doc.data();
    return UserModel(
        doc.id,
        json['uid'] as String,
        json['email'] as String,
        json['displayName'] as String,
        json['phone'] as String,
        json['photoUrl'] as String,
        json['experience']
            .map<UserExperienceModel>((e) => UserExperienceModel.fromJson(e))
            .toList(),
        json['userSkill'] as double,
        json['userSkillVerified'] as double,
        UserStatModel.fromJson(json['userStat']));
  }

  factory UserModel.fromJson(Map<dynamic, dynamic> json) {
    return UserModel(
        null,
        json['uid'] as String,
        json['email'] as String,
        json['displayName'] as String,
        json['phone'] as String,
        json['photoUrl'] as String,
        json['experience']
            .map<UserExperienceModel>((e) => UserExperienceModel.fromJson(e))
            .toList(),
        json['userSkill'] as double,
        json['userSkillVerified'] as double,
        UserStatModel.fromJson(json['userStat']));
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = this.uid;
    data['email'] = this.email;
    data['displayName'] = this.displayName;
    data['phone'] = this.phone;
    data['photoUrl'] = this.photoUrl;
    data['experience'] = this.experience.map((e) => e.toJson()).toList();
    data['userSkill'] = this.userSkill;
    data['userSkillVerified'] = this.userSkillVerified;
    data['userStat'] = (this.userStat == null) ? null : this.userStat.toJson();
    return data;
  }
}
