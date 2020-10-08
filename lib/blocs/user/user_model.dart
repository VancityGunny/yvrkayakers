import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String phone;
  final String photoUrl;

  UserModel(this.uid, this.email, this.displayName, this.phone, this.photoUrl);

  @override
  List<Object> get props => [uid, email, displayName, phone, photoUrl];

  factory UserModel.fromJson(Map<dynamic, dynamic> json) {
    return UserModel(
        json['uid'] as String,
        json['email'] as String,
        json['displayName'] as String,
        json['phone'] as String,
        json['photoUrl'] as String);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = this.uid;
    data['email'] = this.email;
    data['displayName'] = this.displayName;
    data['phone'] = this.phone;
    data['photoUrl'] = this.photoUrl;
    return data;
  }
}
