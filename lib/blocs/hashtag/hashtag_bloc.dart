import 'dart:async';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:yvrkayakers/blocs/hashtag/index.dart';

class HashtagBloc extends Bloc<HashtagEvent, HashtagState> {
  // todo: check singleton for logic in project
  // use GetIt for DI in projct

  @override
  Future<void> close() async {
    // dispose objects
    await super.close();
  }

  @override
  HashtagState get initialState => UnHashtagState(0);

  @override
  Stream<HashtagState> mapEventToState(
    HashtagEvent event,
  ) async* {
    try {
      yield* event.applyAsync(currentState: state, bloc: this);
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'HashtagBloc', error: _, stackTrace: stackTrace);
      yield state;
    }
  }
}
