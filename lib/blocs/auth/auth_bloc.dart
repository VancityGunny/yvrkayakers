import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yvrkayakers/blocs/auth/index.dart';
import 'package:yvrkayakers/blocs/user/user_model.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  StreamController authController;
  final BehaviorSubject<UserModel> currentAuth = BehaviorSubject<UserModel>();

  initStream() {
    var collectionReference = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid);
    authController = StreamController.broadcast();

    authController.addStream(collectionReference
        .snapshots()); // get all river for now, to be limit to nearby later
    authController.stream.listen((event) {
      DocumentSnapshot docSnapshot = event;
      currentAuth.add(UserModel.fromFire(docSnapshot));
      //also update loggedinuser
    });
  }

  AuthBloc({@required AuthRepository authRepository})
      : assert(AuthRepository != null),
        _authRepository = authRepository;

  @override
  AuthState get initialState => UnAuthState(0);

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    if (event is AppStartedEvent) {
      yield* _mapAppStartedToState();
    } else if (event is LoggedInEvent) {
      yield* _mapLoggedInToState();
    } else if (event is LoggedOutEvent) {
      yield* _mapLoggedOutToState();
    } else if (event is LogInWithGooglePressedEvent) {
      yield* _mapLoginWithGooglePressedToState();
    } else if (event is LogInWithPhonePressedEvent) {
      yield* _mapLoginWithPhonePressedToState(event);
    } else if (event is ChooseUserNameEvent) {
      yield* _mapChooseUserNameToState(event);
    }
  }

  Stream<AuthState> _mapAppStartedToState() async* {
    try {
      final isSignedIn = await _authRepository.isSignedIn();

      if (isSignedIn) {
        final user = await _authRepository.getUser();
        // if found user record
        if (user != null) {
          if (user.phone.isNotEmpty && user.userName.isNotEmpty) {
            // must logged in with phone number verified and username verified
            yield AuthenticatedAuthState(0, user.displayName);
          } else {
            if (user.phone.isEmpty) {
              // if missing phone then do phone first
              yield PhoneVerificationAuthState(0);
            } else if (user.userName.isEmpty) {
              yield UserNameVerificationAuthState(0);
            } else {
              yield LogInFailureAuthState(0, "Invalid State");
            }
          }
        } else {
          // if can't find user recrod then it's unauthenticated
          yield PhoneVerificationAuthState(0);
        }
      } else {
        // if status is not signed in then it's unauthenticated
        yield UnauthenticatedAuthState(0);
      }
    } catch (_) {
      yield LogInFailureAuthState(0, _.toString());
    }
  }

  Stream<AuthState> _mapLoggedInToState() async* {
    final user = await _authRepository.getUser();
    if (user != null) {
      if (user.phone.isNotEmpty && user.userName.isNotEmpty) {
        // must logged in with phone number verified and username verified
        yield AuthenticatedAuthState(0, user.displayName);
      } else {
        if (user.phone.isEmpty) {
          // if missing phone then do phone first
          yield PhoneVerificationAuthState(0);
        } else if (user.userName.isEmpty) {
          yield UserNameVerificationAuthState(0);
        } else {
          yield LogInFailureAuthState(0, "Invalid State");
        }
      }
    } else {
      // if can't find user recrod then it's unauthenticated
      yield PhoneVerificationAuthState(0);
    }
  }

  Stream<AuthState> _mapLoggedOutToState() async* {
    _authRepository.signOut();
    yield UnauthenticatedAuthState(0);
  }

  Stream<AuthState> _mapLoginWithGooglePressedToState() async* {
    try {
      await _authRepository.signInWithGoogle();

      yield LogInSuccessAuthState(0);
    } catch (error) {
      yield LogInFailureAuthState(0, error.toString());
    }
  }

  Stream<AuthState> _mapLoginWithPhonePressedToState(
      LogInWithPhonePressedEvent event) async* {
    try {
      await _authRepository.signInWithPhoneNumber(
          event.credential, event.phoneNumber, event.country);

      yield UserNameVerificationAuthState(0);
    } catch (error) {
      yield LogInFailureAuthState(0, error.toString());
    }
  }

  Stream<AuthState> _mapChooseUserNameToState(
      ChooseUserNameEvent event) async* {
    try {
      await _authRepository.selectNewUserName(event.newUserName);
      final user = await _authRepository.getUser();
      yield AuthenticatedAuthState(0, user.displayName);
    } catch (error) {
      yield LogInFailureAuthState(0, error.toString());
    }
  }
}
