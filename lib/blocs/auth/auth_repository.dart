import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';
import 'package:yvrkayakers/blocs/user/user_model.dart';
import 'package:yvrkayakers/blocs/user/user_provider.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  static final _firestore = Firestore.instance;
  final GoogleSignIn _googleSignIn;

  AuthRepository({FirebaseAuth firebaseAuth, GoogleSignIn googleSignin})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignin ?? GoogleSignIn();

  Future<FirebaseUser> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _firebaseAuth.signInWithCredential(credential);
    var user = await _firebaseAuth.currentUser();

    return user;
  }

  Future<void> signInWithPhoneNumber(
      AuthCredential credential, String phoneNumber) async {
    // now we merge with existing firebase user
    FirebaseUser currentUser = await _firebaseAuth.currentUser();
    await currentUser.linkWithCredential(credential).then((value) async {
      await createOrAssumeUser(value, currentUser, phoneNumber);
    });

    // AuthResult authResult =
    //     await _firebaseAuth.signInWithCredential(credential);
  }

  Future createOrAssumeUser(
      AuthResult authResult, FirebaseUser currentUser, phoneNumber) async {
    if (authResult.user == null) {
      return;
    }

    var userProvider = new UserProvider();
    // update user add phone number and marked as verified
    var foundUsers = await _firestore
        .collection('/users')
        .where('uid', isEqualTo: currentUser.uid)
        .getDocuments();
    // assume account found by id
    if (foundUsers.documents.length > 0) {
      await userProvider.assumeUser(
          foundUsers.documents.first.documentID,
          new UserModel(currentUser.uid, currentUser.email,
              currentUser.displayName, phoneNumber, currentUser.photoUrl));
      var session = FlutterSession();
      await session.set("currentUserId", foundUsers.documents.first.documentID);
      return; // if existing then just update this and return
    } else {
      // can't find match by uid
      // try to find match by phone number
      var foundUsersByPhone = await _firestore
          .collection('/users')
          .where('phone', isEqualTo: phoneNumber)
          .getDocuments();
      // create new user if not already exists

      if (foundUsersByPhone.documents.length == 0) {
        // check if user record does not exist then create the record
        var uuid = new Uuid();
        var userId = uuid.v1();
        await userProvider.addUser(
            userId.toString(),
            new UserModel(currentUser.uid, currentUser.email,
                currentUser.displayName, phoneNumber, currentUser.photoUrl));
        var session = FlutterSession();
        await session.set("currentUserId", userId);
      } else {
        // assume user
        await userProvider.assumeUser(
            foundUsersByPhone.documents.first.documentID,
            new UserModel(currentUser.uid, currentUser.email,
                currentUser.displayName, phoneNumber, currentUser.photoUrl));
        var session = FlutterSession();
        await session.set(
            "currentUserId", foundUsersByPhone.documents.first.documentID);
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
    final currentUser = await _firebaseAuth.currentUser();
    return currentUser != null;
  }

  Future<UserModel> getUser() async {
    var user = await _firebaseAuth.currentUser();

    var foundUsers = await _firestore
        .collection('/users')
        .where('uid', isEqualTo: user.uid)
        .getDocuments();
    if (foundUsers.documents.length > 0) {
      var loggedInUser = UserModel.fromJson(foundUsers.documents[0].data);
      var session = FlutterSession();
      await session.set("loggedInUser", loggedInUser);
      await session.set("currentUserId", foundUsers.documents[0].documentID);
      return loggedInUser;
    } else {
      return null;
    }
  }
}
