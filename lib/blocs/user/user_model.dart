import 'package:equatable/equatable.dart';

class UserExperienceModel extends Equatable {
  final double riverGrade;
  int runCount;

  UserExperienceModel(this.riverGrade, this.runCount);

  @override
  // TODO: implement props
  List<Object> get props => [riverGrade, runCount];

  factory UserExperienceModel.fromJson(Map<dynamic, dynamic> json) {
    return UserExperienceModel(
        json['riverGrade'] as double, json['runCount'] as int);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['riverGrade'] = this.riverGrade;
    data['runCount'] = this.runCount;
    return data;
  }
}

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String phone;
  final String photoUrl;
  final List<UserExperienceModel> experience;

  UserModel(this.uid, this.email, this.displayName, this.phone, this.photoUrl,
      this.experience);

  @override
  List<Object> get props =>
      [uid, email, displayName, phone, photoUrl, experience];

  factory UserModel.fromJson(Map<dynamic, dynamic> json) {
    return UserModel(
      json['uid'] as String,
      json['email'] as String,
      json['displayName'] as String,
      json['phone'] as String,
      json['photoUrl'] as String,
      json['experience']
          .map<UserExperienceModel>((e) => UserExperienceModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = this.uid;
    data['email'] = this.email;
    data['displayName'] = this.displayName;
    data['phone'] = this.phone;
    data['photoUrl'] = this.photoUrl;
    data['experience'] = this.experience.map((e) => e.toJson()).toList();
    return data;
  }
}
