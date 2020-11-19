import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yvrkayakers/blocs/user/user_model.dart';
import 'package:yvrkayakers/common/myconstants.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class UserProvider {
  Future<String> addUser(UserModel newUser) async {
    // if it's not already exists then add new user first
    var newUserObj = _firestore.collection('/users').doc(newUser.id);

    newUserObj.set(newUser.toJson());
    return newUserObj.id;
  }

  Future<void> assumeUser(UserModel userModel) async {
    _firestore.collection('/users').doc(userModel.id).update({
      'uid': userModel.uid,
      'phone': userModel.phone,
      'displayName': userModel.displayName,
      'photoUrl': userModel.photoUrl
    });
  }
}
