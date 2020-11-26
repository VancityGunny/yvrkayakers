import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:yvrkayakers/blocs/user/user_model.dart';
import 'package:yvrkayakers/blocs/user/user_provider.dart';
import 'package:yvrkayakers/common/myconstants.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  static final _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn;

  AuthRepository({FirebaseAuth firebaseAuth, GoogleSignIn googleSignin})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignin ?? GoogleSignIn();

  Future<User> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _firebaseAuth.signInWithCredential(credential);
    var user = _firebaseAuth.currentUser;

    return user;
  }

  Future<void> signInWithPhoneNumber(
      AuthCredential credential, String phoneNumber) async {
    // now we merge with existing firebase user
    User currentUser = _firebaseAuth.currentUser;
    await currentUser.linkWithCredential(credential).then((value) async {
      await createOrAssumeUser(value, currentUser, phoneNumber);
    });

    // AuthResult authResult =
    //     await _firebaseAuth.signInWithCredential(credential);
  }

  Future createOrAssumeUser(
      UserCredential userCred, User currentUser, phoneNumber) async {
    if (userCred.user == null) {
      return;
    }

    var userProvider = new UserProvider();

    List<UserExperienceModel> experience = new List<UserExperienceModel>();
    MyConstants.RIVER_GRADES.forEach((element) {
      experience.add(UserExperienceModel(element, 0, 0));
    });
    // update user add phone number and marked as verified
    var foundUsers =
        await _firestore.collection('/users').doc(currentUser.uid).get();

    // assume account found by id
    if (foundUsers.exists) {
      await userProvider.assumeUser(new UserModel(
          currentUser.email,
          currentUser.displayName,
          phoneNumber,
          currentUser.photoURL,
          experience,
          0.0,
          0.0,
          null,
          currentUser.uid));
      return; // if existing then just update this and return
    } else {
      // can't find match by uid
      // try to find match by phone number
      var foundUsersByPhone = await _firestore
          .collection('/users')
          .where('phone', isEqualTo: phoneNumber)
          .get();
      // create new user if not already exists

      if (foundUsersByPhone.docs.length == 0) {
        // check if user record does not exist then create the record
        await userProvider.addUser(new UserModel(
            currentUser.email,
            currentUser.displayName,
            phoneNumber,
            currentUser.photoURL,
            experience,
            0.0,
            0.0,
            null,
            FirebaseAuth.instance.currentUser.uid));
      } else {
        // assume user
        await userProvider.assumeUser(new UserModel(
            currentUser.email,
            currentUser.displayName,
            phoneNumber,
            currentUser.photoURL,
            experience,
            0.0,
            0.0,
            null,
            FirebaseAuth.instance.currentUser.uid));
      }
      return;
    }
  }

  Future<void> signOut() async {
    return Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<bool> isSignedIn() async {
    final currentUser = _firebaseAuth.currentUser;
    var session = FlutterSession();
    var logCurrentUser = await session.get("loggedInUser");
    return currentUser != null && logCurrentUser != null;
  }

  Future<UserModel> getUser() async {
    var user = _firebaseAuth.currentUser;

    var foundUsers = await _firestore.collection('/users').doc(user.uid).get();
    if (foundUsers.exists) {
      UserShortModel loggedInUser = UserModel.fromFire(foundUsers);
      var session = FlutterSession();
      await session.set("loggedInUser", loggedInUser);
      return loggedInUser;
    } else {
      return null;
    }
  }
}
