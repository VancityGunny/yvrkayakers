import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  /// notify change state without deep clone state
  final int version;

  final List propss;
  AuthState(this.version, [this.propss]);

  @override
  List<Object> get props => ([version, ...propss ?? []]);
}

/// UnInitialized
class UnAuthState extends AuthState {
  UnAuthState(int version) : super(version);

  @override
  String toString() => 'UnAuthState';
}

/// Initialized
class InAuthState extends AuthState {
  final String hello;

  InAuthState(int version, this.hello) : super(version, [hello]);

  @override
  String toString() => 'InAuthState $hello';
}

class ErrorAuthState extends AuthState {
  final String errorMessage;

  ErrorAuthState(int version, this.errorMessage)
      : super(version, [errorMessage]);

  @override
  String toString() => 'ErrorAuthState';
}

class AuthenticatedAuthState extends AuthState {
  final String displayName;

  AuthenticatedAuthState(int version, this.displayName)
      : super(version, [displayName]);

  @override
  String toString() => 'AuthenticatedAuthState { displayName: $displayName }';

  @override
  // TODO: implement props
  List<Object> get props => null;
}

class UnauthenticatedAuthState extends AuthState {
  UnauthenticatedAuthState(int version) : super(version);

  @override
  String toString() => 'UnauthenticatedAuthState';

  @override
  // TODO: implement props
  List<Object> get props => null;
}

class LogInSuccessAuthState extends AuthState {
  LogInSuccessAuthState(int version) : super(version);

  @override
  String toString() => 'LogInSuccessAuthState';

  @override
  // TODO: implement props
  List<Object> get props => null;
}

class LogInFailureAuthState extends AuthState {
  LogInFailureAuthState(int version) : super(version);

  @override
  String toString() => 'LogInFailureAuthState';

  @override
  // TODO: implement props
  List<Object> get props => null;
}

class PhoneVerificationAuthState extends AuthState {
  PhoneVerificationAuthState(int version) : super(version);

  @override
  String toString() => 'PhoneVerificationAuthState';

  @override
  // TODO: implement props
  List<Object> get props => null;
}
