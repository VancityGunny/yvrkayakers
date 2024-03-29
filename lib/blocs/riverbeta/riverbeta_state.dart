import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';
import 'package:yvrkayakers/blocs/hashtag/index.dart';

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
}

/// Initialized
class InRiverbetaState extends RiverbetaState {
  final String hello;

  InRiverbetaState(int version, this.hello) : super(version, [hello]);

  @override
  String toString() => 'InRiverbetaState $hello';
}

class ErrorRiverbetaState extends RiverbetaState {
  final String errorMessage;

  ErrorRiverbetaState(int version, this.errorMessage)
      : super(version, [errorMessage]);

  @override
  String toString() => 'ErrorRiverbetaState';
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
  final RiverAnnualStatModel foundRiverStat;
  final HashtagModel foundRiverHashtag;
  FoundRiverbetaState(int version,
      {@required this.foundRiver, this.foundRiverStat, this.foundRiverHashtag})
      : super(version);
}

class UpdatedRiverbetaState extends RiverbetaState {
  final String riverId;
  UpdatedRiverbetaState(int version, {@required this.riverId}) : super(version);
}
