import 'dart:async';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:yvrkayakers/blocs/riverlog/index.dart';

class RiverlogBloc extends Bloc<RiverlogEvent, RiverlogState> {
  @override
  RiverlogState get initialState => UnRiverlogState(0);

  @override
  Stream<RiverlogState> mapEventToState(
    RiverlogEvent event,
  ) async* {
    try {
      yield* event.applyAsync(currentState: state, bloc: this);
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'RiverlogBloc', error: _, stackTrace: stackTrace);
      yield state;
    }
  }
}
