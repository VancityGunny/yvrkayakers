import 'dart:async';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:yvrkayakers/blocs/trip/index.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  // todo: check singleton for logic in project
  // use GetIt for DI in projct

  @override
  Future<void> close() async {
    // dispose objects
    await super.close();
  }

  @override
  TripState get initialState => UnTripState(0);

  @override
  Stream<TripState> mapEventToState(
    TripEvent event,
  ) async* {
    try {
      yield* event.applyAsync(currentState: state, bloc: this);
    } catch (_, stackTrace) {
      developer.log('$_', name: 'TripBloc', error: _, stackTrace: stackTrace);
      yield state;
    }
  }
}
