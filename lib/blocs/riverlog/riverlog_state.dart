import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:yvrkayakers/blocs/riverlog/index.dart';
import 'package:yvrkayakers/blocs/hashtag/index.dart';

abstract class RiverlogState extends Equatable {
  /// notify change state without deep clone state
  final int version;

  final List propss;
  RiverlogState(this.version, [this.propss]);

  @override
  List<Object> get props => ([version, ...propss ?? []]);
}

/// UnInitialized
class UnRiverlogState extends RiverlogState {
  UnRiverlogState(int version) : super(version);

  @override
  String toString() => 'UnRiverlogState';

  @override
  UnRiverlogState getStateCopy() {
    return UnRiverlogState(0);
  }

  @override
  UnRiverlogState getNewVersion() {
    return UnRiverlogState(version + 1);
  }
}

/// Initialized
class InRiverlogState extends RiverlogState {
  final String hello;

  InRiverlogState(int version, this.hello) : super(version, [hello]);

  @override
  String toString() => 'InRiverlogState $hello';

  @override
  InRiverlogState getStateCopy() {
    return InRiverlogState(version, hello);
  }

  @override
  InRiverlogState getNewVersion() {
    return InRiverlogState(version + 1, hello);
  }
}

class ErrorRiverlogState extends RiverlogState {
  final String errorMessage;

  ErrorRiverlogState(int version, this.errorMessage)
      : super(version, [errorMessage]);

  @override
  String toString() => 'ErrorRiverlogState';

  @override
  ErrorRiverlogState getStateCopy() {
    return ErrorRiverlogState(version, errorMessage);
  }

  @override
  ErrorRiverlogState getNewVersion() {
    return ErrorRiverlogState(version + 1, errorMessage);
  }
}

class AddedRiverlogState extends RiverlogState {
  final String newLogId;
  AddedRiverlogState(int version, {@required this.newLogId}) : super(version);
  @override
  List<Object> get props => [newLogId];

  @override
  String toString() => 'AddedRiverlogState';
}

class LoadedUserRiverlogState extends RiverlogState {
  final List<RiverlogModel> riverLogs;
  LoadedUserRiverlogState(int version, {@required this.riverLogs})
      : super(version);
}

class LoadedRiverlogState extends RiverlogState {
  final RiverlogModel riverLog;
  LoadedRiverlogState(int version, {@required this.riverLog}) : super(version);
}

class FoundRiverlogState extends RiverlogState {
  final RiverlogModel foundRiverlog;
  final HashtagModel foundRiverlogHashtag;
  FoundRiverlogState(int version,
      {@required this.foundRiverlog, this.foundRiverlogHashtag})
      : super(version);
}
