import 'package:equatable/equatable.dart';

abstract class TripState extends Equatable {
  /// notify change state without deep clone state
  final int version;
  
  final List propss;
  TripState(this.version,[this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  TripState getStateCopy();

  TripState getNewVersion();

  @override
  List<Object> get props => ([version, ...propss ?? []]);
}

/// UnInitialized
class UnTripState extends TripState {

  UnTripState(int version) : super(version);

  @override
  String toString() => 'UnTripState';

  @override
  UnTripState getStateCopy() {
    return UnTripState(0);
  }

  @override
  UnTripState getNewVersion() {
    return UnTripState(version+1);
  }
}

/// Initialized
class InTripState extends TripState {
  final String hello;

  InTripState(int version, this.hello) : super(version, [hello]);

  @override
  String toString() => 'InTripState $hello';

  @override
  InTripState getStateCopy() {
    return InTripState(version, hello);
  }

  @override
  InTripState getNewVersion() {
    return InTripState(version+1, hello);
  }
}

class ErrorTripState extends TripState {
  final String errorMessage;

  ErrorTripState(int version, this.errorMessage): super(version, [errorMessage]);
  
  @override
  String toString() => 'ErrorTripState';

  @override
  ErrorTripState getStateCopy() {
    return ErrorTripState(version, errorMessage);
  }

  @override
  ErrorTripState getNewVersion() {
    return ErrorTripState(version+1, 
    errorMessage);
  }
}
