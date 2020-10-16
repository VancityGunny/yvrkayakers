import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';

abstract class RiverbetaState extends Equatable {
  /// notify change state without deep clone state
  final int version;

  final List propss;
  RiverbetaState(this.version, [this.propss]);

  @override
  List<Object> get props => ([version, ...propss ?? []]);
}

/// UnInitialized
class UnRiverbetaState extends RiverbetaState {
  UnRiverbetaState(int version) : super(version);

  @override
  String toString() => 'UnRiverbetaState';

  @override
  UnRiverbetaState getStateCopy() {
    return UnRiverbetaState(0);
  }

  @override
  UnRiverbetaState getNewVersion() {
    return UnRiverbetaState(version + 1);
  }
}

/// Initialized
class InRiverbetaState extends RiverbetaState {
  final String hello;

  InRiverbetaState(int version, this.hello) : super(version, [hello]);

  @override
  String toString() => 'InRiverbetaState $hello';

  @override
  InRiverbetaState getStateCopy() {
    return InRiverbetaState(version, hello);
  }

  @override
  InRiverbetaState getNewVersion() {
    return InRiverbetaState(version + 1, hello);
  }
}

class ErrorRiverbetaState extends RiverbetaState {
  final String errorMessage;

  ErrorRiverbetaState(int version, this.errorMessage)
      : super(version, [errorMessage]);

  @override
  String toString() => 'ErrorRiverbetaState';

  @override
  ErrorRiverbetaState getStateCopy() {
    return ErrorRiverbetaState(version, errorMessage);
  }

  @override
  ErrorRiverbetaState getNewVersion() {
    return ErrorRiverbetaState(version + 1, errorMessage);
  }
}

class AddedRiverbetaState extends RiverbetaState {
  final RiverbetaModel newRiver;
  AddedRiverbetaState(int version, {@required this.newRiver}) : super(version);
  @override
  List<Object> get props => [newRiver];

  @override
  String toString() => 'AddedRiverbetaState';
}

class FoundNearbyRiverbetaState extends RiverbetaState {
  final List<RiverbetaModel> foundRivers;
  FoundNearbyRiverbetaState(int version, {@required this.foundRivers})
      : super(version);
}

class FoundRiverbetaState extends RiverbetaState {
  final RiverbetaModel foundRiver;
  FoundRiverbetaState(int version, {@required this.foundRiver})
      : super(version);
}
