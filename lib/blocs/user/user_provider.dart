import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yvrkayakers/blocs/user/user_model.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class UserProvider {
  Future<String> addUser(UserModel newUser) async {
    // if it's not already exists then add new user first
    var newUserObj = _firestore.collection('/users').doc(newUser.uid);

    newUserObj.set(newUser.toFire());
    return newUserObj.id;
  }

  Future<void> assumeUser(UserModel userModel) async {
    _firestore.collection('/users').doc(userModel.uid).update({
      'phone': userModel.phone,
      'displayName': userModel.displayName,
      'photoUrl': userModel.photoUrl
    });
  }
}
