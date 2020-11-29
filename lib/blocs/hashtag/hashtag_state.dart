import 'package:equatable/equatable.dart';

abstract class HashtagState extends Equatable {
  /// notify change state without deep clone state
  final int version;
  
  final List propss;
  HashtagState(this.version,[this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  HashtagState getStateCopy();

  HashtagState getNewVersion();

  @override
  List<Object> get props => ([version, ...propss ?? []]);
}

/// UnInitialized
class UnHashtagState extends HashtagState {

  UnHashtagState(int version) : super(version);

  @override
  String toString() => 'UnHashtagState';

  @override
  UnHashtagState getStateCopy() {
    return UnHashtagState(0);
  }

  @override
  UnHashtagState getNewVersion() {
    return UnHashtagState(version+1);
  }
}

/// Initialized
class InHashtagState extends HashtagState {
  final String hello;

  InHashtagState(int version, this.hello) : super(version, [hello]);

  @override
  String toString() => 'InHashtagState $hello';

  @override
  InHashtagState getStateCopy() {
    return InHashtagState(version, hello);
  }

  @override
  InHashtagState getNewVersion() {
    return InHashtagState(version+1, hello);
  }
}

class ErrorHashtagState extends HashtagState {
  final String errorMessage;

  ErrorHashtagState(int version, this.errorMessage): super(version, [errorMessage]);
  
  @override
  String toString() => 'ErrorHashtagState';

  @override
  ErrorHashtagState getStateCopy() {
    return ErrorHashtagState(version, errorMessage);
  }

  @override
  ErrorHashtagState getNewVersion() {
    return ErrorHashtagState(version+1, 
    errorMessage);
  }
}
