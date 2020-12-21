import 'dart:async';
import 'dart:developer' as developer;

import 'package:yvrkayakers/blocs/hashtag/index.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';
import 'package:meta/meta.dart';

@immutable
abstract class RiverbetaEvent {
  Stream<RiverbetaState> applyAsync(
      {RiverbetaState currentState, RiverbetaBloc bloc});
  final RiverbetaRepository _riverbetaRepository = RiverbetaRepository();
  final HashtagRepository _hashtagRepository = HashtagRepository();
}

class UnRiverbetaEvent extends RiverbetaEvent {
  @override
  Stream<RiverbetaState> applyAsync(
      {RiverbetaState currentState, RiverbetaBloc bloc}) async* {
    yield UnRiverbetaState(0);
  }
}

class LoadRiverbetaEvent extends RiverbetaEvent {
  final bool isError;
  @override
  String toString() => 'LoadRiverbetaEvent';

  LoadRiverbetaEvent(this.isError);

  @override
  Stream<RiverbetaState> applyAsync(
      {RiverbetaState currentState, RiverbetaBloc bloc}) async* {
    try {
      yield UnRiverbetaState(0);
      await Future.delayed(Duration(seconds: 1));
      _riverbetaRepository.test(isError);
      yield InRiverbetaState(0, 'Hello world');
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadRiverbetaEvent', error: _, stackTrace: stackTrace);
      yield ErrorRiverbetaState(0, _?.toString());
    }
  }
}

class AddingRiverbetaEvent extends RiverbetaEvent {
  final RiverbetaModel newRiver;
  AddingRiverbetaEvent(this.newRiver);
  @override
  Stream<RiverbetaState> applyAsync(
      {RiverbetaState currentState, RiverbetaBloc bloc}) async* {
    var success = await _riverbetaRepository.addRiver(newRiver);
    if (success != null) {
      yield AddedRiverbetaState(0, newRiver: newRiver);
    }
  }
}

class SuggestingRiverbetaEvent extends RiverbetaEvent {
  final RiverbetaModel newRiver;
  SuggestingRiverbetaEvent(this.newRiver);
  @override
  Stream<RiverbetaState> applyAsync(
      {RiverbetaState currentState, RiverbetaBloc bloc}) async* {
    var success = await _riverbetaRepository.suggestRiver(newRiver);
    if (success != null) {
      yield AddedRiverbetaState(0, newRiver: newRiver);
    }
  }
}

class SearchingNearbyRiverbetaEvent extends RiverbetaEvent {
  final GeoFirePoint center;
  final double distance;
  SearchingNearbyRiverbetaEvent(this.center, this.distance);
  @override
  Stream<RiverbetaState> applyAsync(
      {RiverbetaState currentState, RiverbetaBloc bloc}) async* {
    var foundRivers =
        await _riverbetaRepository.getNearbyRivers(center, distance);
    yield FoundNearbyRiverbetaState(0, foundRivers: foundRivers);
  }
}

class FetchingRiverbetaEvent extends RiverbetaEvent {
  final String riverId;
  FetchingRiverbetaEvent(this.riverId);

  @override
  Stream<RiverbetaState> applyAsync(
      {RiverbetaState currentState, RiverbetaBloc bloc}) async* {
    yield UnRiverbetaState(0);
    var foundRiver = await _riverbetaRepository.getRiverById(riverId);
    var foundRiverStat = await _riverbetaRepository.getRiverStat(riverId);
    var foundRiverHashtag =
        await _hashtagRepository.getHashtag(foundRiver.riverHashtag());
    yield FoundRiverbetaState(0,
        foundRiver: foundRiver,
        foundRiverStat: foundRiverStat,
        foundRiverHashtag: foundRiverHashtag);
  }
}

class UpdatingVideosRiverbetaEvent extends RiverbetaEvent {
  final String riverHashtag;
  final List<ExtObjectLink> videoList;
  UpdatingVideosRiverbetaEvent(this.riverHashtag, this.videoList);
  @override
  Stream<RiverbetaState> applyAsync(
      {RiverbetaState currentState, RiverbetaBloc bloc}) async* {
    try {
      await _hashtagRepository.updateHashtagVideos(riverHashtag, videoList);
      yield UpdatedRiverbetaState(0, riverId: riverHashtag);
    } catch (e) {}
  }
}
