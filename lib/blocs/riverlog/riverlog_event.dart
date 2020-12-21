import 'dart:async';
import 'dart:developer' as developer;
import 'package:yvrkayakers/blocs/riverlog/index.dart';
import 'package:meta/meta.dart';
import 'package:yvrkayakers/blocs/hashtag/index.dart';

@immutable
abstract class RiverlogEvent {
  Stream<RiverlogState> applyAsync(
      {RiverlogState currentState, RiverlogBloc bloc});
  final RiverlogRepository _riverlogRepository = RiverlogRepository();
  final HashtagRepository _hashtagRepository = HashtagRepository();
}

class UnRiverlogEvent extends RiverlogEvent {
  @override
  Stream<RiverlogState> applyAsync(
      {RiverlogState currentState, RiverlogBloc bloc}) async* {
    yield UnRiverlogState(0);
  }
}

class LoadUserRiverlogEvent extends RiverlogEvent {
  final String riverlogUserId;
  @override
  String toString() => 'LoadUserRiverlogEvent';

  LoadUserRiverlogEvent(this.riverlogUserId);

  @override
  Stream<RiverlogState> applyAsync(
      {RiverlogState currentState, RiverlogBloc bloc}) async* {
    try {
      yield UnRiverlogState(0);
      // load river
      var foundRivers =
          await _riverlogRepository.getRiverLogByUser(riverlogUserId);
      yield LoadedUserRiverlogState(0, riverLogs: foundRivers);
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadUserRiverlogEvent', error: _, stackTrace: stackTrace);
      yield ErrorRiverlogState(0, _?.toString());
    }
  }
}

class LoadRiverlogEvent extends RiverlogEvent {
  final String riverlogId;
  final String userId;
  @override
  String toString() => 'LoadRiverlogEvent';

  LoadRiverlogEvent(this.userId, this.riverlogId);

  @override
  Stream<RiverlogState> applyAsync(
      {RiverlogState currentState, RiverlogBloc bloc}) async* {
    try {
      yield UnRiverlogState(0);
      // load river
      var foundRiver =
          await _riverlogRepository.getRiverLogById(userId, riverlogId);
      yield LoadedRiverlogState(0, riverLog: foundRiver);
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadRiverlogEvent', error: _, stackTrace: stackTrace);
      yield ErrorRiverlogState(0, _?.toString());
    }
  }
}

class AddingRiverlogEvent extends RiverlogEvent {
  final RiverlogModel newRiverlog;
  @override
  String toString() => 'AddingRiverlogEvent';

  AddingRiverlogEvent(this.newRiverlog);

  @override
  Stream<RiverlogState> applyAsync(
      {RiverlogState currentState, RiverlogBloc bloc}) async* {
    try {
      yield UnRiverlogState(0);
      // load river
      var result = await _riverlogRepository.addRiverLog(newRiverlog);
      yield AddedRiverlogState(0, newLogId: result);
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'AddingRiverlogEvent', error: _, stackTrace: stackTrace);
      yield ErrorRiverlogState(0, _?.toString());
    }
  }
}

class FetchingRiverlogEvent extends RiverlogEvent {
  final String selectedUserId;
  final String riverlogId;
  FetchingRiverlogEvent(this.selectedUserId, this.riverlogId);

  @override
  Stream<RiverlogState> applyAsync(
      {RiverlogState currentState, RiverlogBloc bloc}) async* {
    yield UnRiverlogState(0);
    var foundRiverlog =
        await _riverlogRepository.getRiverLogById(selectedUserId, riverlogId);
    var foundRiverHashtag =
        await _hashtagRepository.getHashtag(foundRiverlog.riverlogHashtag());
    yield FoundRiverlogState(0,
        foundRiverlog: foundRiverlog, foundRiverlogHashtag: foundRiverHashtag);
  }
}
