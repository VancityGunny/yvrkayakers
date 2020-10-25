import 'dart:async';
import 'dart:developer' as developer;

import 'package:yvrkayakers/blocs/riverlog/index.dart';
import 'package:meta/meta.dart';

@immutable
abstract class RiverlogEvent {
  Stream<RiverlogState> applyAsync(
      {RiverlogState currentState, RiverlogBloc bloc});
  final RiverlogRepository _riverlogRepository = RiverlogRepository();
}

class UnRiverlogEvent extends RiverlogEvent {
  @override
  Stream<RiverlogState> applyAsync({RiverlogState currentState, RiverlogBloc bloc}) async* {
    yield UnRiverlogState(0);
  }
}

class LoadRiverlogEvent extends RiverlogEvent {
   
  final bool isError;
  @override
  String toString() => 'LoadRiverlogEvent';

  LoadRiverlogEvent(this.isError);

  @override
  Stream<RiverlogState> applyAsync(
      {RiverlogState currentState, RiverlogBloc bloc}) async* {
    try {
      yield UnRiverlogState(0);
      await Future.delayed(Duration(seconds: 1));
      _riverlogRepository.test(isError);
      yield InRiverlogState(0, 'Hello world');
    } catch (_, stackTrace) {
      developer.log('$_', name: 'LoadRiverlogEvent', error: _, stackTrace: stackTrace);
      yield ErrorRiverlogState(0, _?.toString());
    }
  }
}
