import 'dart:async';
import 'dart:developer' as developer;

import 'package:yvrkayakers/blocs/trip/index.dart';
import 'package:meta/meta.dart';

@immutable
abstract class TripEvent {
  Stream<TripState> applyAsync({TripState currentState, TripBloc bloc});
  final TripRepository _tripRepository = TripRepository();
}

class UnTripEvent extends TripEvent {
  @override
  Stream<TripState> applyAsync({TripState currentState, TripBloc bloc}) async* {
    yield UnTripState(0);
  }
}

class LoadTripEvent extends TripEvent {
  final bool isError;
  @override
  String toString() => 'LoadTripEvent';

  LoadTripEvent(this.isError);

  @override
  Stream<TripState> applyAsync({TripState currentState, TripBloc bloc}) async* {
    try {
      yield UnTripState(0);
      await Future.delayed(Duration(seconds: 1));
      _tripRepository.test(isError);
      yield InTripState(0, 'Hello world');
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadTripEvent', error: _, stackTrace: stackTrace);
      yield ErrorTripState(0, _?.toString());
    }
  }
}

class AddingTripEvent extends TripEvent {
  final TripModel newTrip;
  @override
  String toString() => 'AddingRiverlogEvent';

  AddingTripEvent(this.newTrip);

  @override
  Stream<TripState> applyAsync({TripState currentState, TripBloc bloc}) async* {
    try {
      yield UnTripState(0);
      // load river
      var result = await _tripRepository.addTrip(newTrip);
      yield AddedTripState(0, newLogId: result);
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'AddingRiverlogEvent', error: _, stackTrace: stackTrace);
      yield ErrorTripState(0, _?.toString());
    }
  }
}
