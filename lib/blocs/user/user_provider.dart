import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yvrkayakers/blocs/user/user_model.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class UserProvider {
  Future<String> addUser(String userId, UserModel newUser) async {
    // if it's not already exists then add new user first
    var newUserObj = _firestore.collection('/users').doc(userId);
    newUserObj.set({
      'uid': newUser.uid,
      'email': newUser.email,
      'phone': newUser.phone,
      'displayName': newUser.displayName
    });
    return newUserObj.id;
  }

  Future<void> assumeUser(String foundUserId, UserModel userModel) async {
    _firestore.collection('/users').doc(foundUserId).update({
      'uid': userModel.uid,
      'phone': userModel.phone,
      'displayName': userModel.displayName,
      'photoUrl': userModel.photoUrl
    });
  }
}
