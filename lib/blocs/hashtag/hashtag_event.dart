import 'dart:async';
import 'dart:developer' as developer;

import 'package:yvrkayakers/blocs/hashtag/index.dart';
import 'package:meta/meta.dart';

@immutable
abstract class HashtagEvent {
  Stream<HashtagState> applyAsync(
      {HashtagState currentState, HashtagBloc bloc});
  final HashtagRepository _hashtagRepository = HashtagRepository();
}

class UnHashtagEvent extends HashtagEvent {
  @override
  Stream<HashtagState> applyAsync({HashtagState currentState, HashtagBloc bloc}) async* {
    yield UnHashtagState(0);
  }
}

class LoadHashtagEvent extends HashtagEvent {
   
  final bool isError;
  @override
  String toString() => 'LoadHashtagEvent';

  LoadHashtagEvent(this.isError);

  @override
  Stream<HashtagState> applyAsync(
      {HashtagState currentState, HashtagBloc bloc}) async* {
    try {
      yield UnHashtagState(0);
      await Future.delayed(Duration(seconds: 1));
      _hashtagRepository.test(isError);
      yield InHashtagState(0, 'Hello world');
    } catch (_, stackTrace) {
      developer.log('$_', name: 'LoadHashtagEvent', error: _, stackTrace: stackTrace);
      yield ErrorHashtagState(0, _?.toString());
    }
  }
}
