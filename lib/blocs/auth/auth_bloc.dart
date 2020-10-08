import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:yvrkayakers/blocs/auth/index.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

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
    }
  }

  Stream<AuthState> _mapAppStartedToState() async* {
    try {
      final isSignedIn = await _authRepository.isSignedIn();

      if (isSignedIn) {
        final user = await _authRepository.getUser();
        if (user != null && user.phone != null) {
          // as long as we have phone number, whether it be from gmail account or verified by phone we don't care
          yield AuthenticatedAuthState(0, user.displayName);
        } else {
          yield PhoneVerificationAuthState(0);
        }
      } else {
        yield UnauthenticatedAuthState(0);
      }
    } catch (_) {
      yield UnauthenticatedAuthState(0);
    }
  }

  Stream<AuthState> _mapLoggedInToState() async* {
    final user = await _authRepository.getUser();
    if (user != null && user.phone != null) {
      // as long as we have phone number, whether it be from gmail account or verified by phone we don't care
      yield AuthenticatedAuthState(0, user.displayName);
    } else {
      yield PhoneVerificationAuthState(0);
    }
  }

  Stream<AuthState> _mapLoggedOutToState() async* {
    yield UnAuthState(0);

    _authRepository.signOut();
  }

  Stream<AuthState> _mapLoginWithGooglePressedToState() async* {
    try {
      await _authRepository.signInWithGoogle();

      yield LogInSuccessAuthState(0);
    } catch (_) {
      yield LogInFailureAuthState(0);
    }
  }

  Stream<AuthState> _mapLoginWithPhonePressedToState(
      LogInWithPhonePressedEvent event) async* {
    try {
      await _authRepository.signInWithPhoneNumber(
          event.credential, event.phoneNumber);

      final user = await _authRepository.getUser();
      yield AuthenticatedAuthState(0, user.displayName);
    } catch (_) {
      yield LogInFailureAuthState(0);
    }
  }
}
