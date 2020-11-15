import 'dart:async';
import 'dart:developer' as developer;

import 'package:yvrkayakers/blocs/trip/index.dart';
import 'package:meta/meta.dart';
import 'package:yvrkayakers/blocs/user/user_model.dart';

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
  String toString() => 'AddingTripEvent';

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
          name: 'AddingTripEvent', error: _, stackTrace: stackTrace);
      yield ErrorTripState(0, _?.toString());
    }
  }
}

class AddingCommentTripEvent extends TripEvent {
  final TripCommentModel newComment;
  final String tripId;
  @override
  String toString() => 'AddingCommentTripEvent';

  AddingCommentTripEvent(this.tripId, this.newComment);

  @override
  Stream<TripState> applyAsync({TripState currentState, TripBloc bloc}) async* {
    try {
      yield UnTripState(0);
      // load river
      var result =
          await _tripRepository.addTripComment(this.tripId, this.newComment);
      yield AddedCommentTripState(0, newLogId: result);
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'AddingCommentTripEvent', error: _, stackTrace: stackTrace);
      yield ErrorTripState(0, _?.toString());
    }
  }
}

class JoinTripEvent extends TripEvent {
  final String tripId;
  final TripParticipantModel newTripParticipant;
  @override
  String toString() => 'JoinTripEvent';

  JoinTripEvent(this.tripId, this.newTripParticipant);

  @override
  Stream<TripState> applyAsync({TripState currentState, TripBloc bloc}) async* {
    try {
      yield UnTripState(0);
      // load river
      var result =
          await _tripRepository.addTripParticipant(tripId, newTripParticipant);
      yield JoinedTripState(0, newLogId: result);
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'JoinTripEvent', error: _, stackTrace: stackTrace);
      yield ErrorTripState(0, _?.toString());
    }
  }
}

class LeaveTripEvent extends TripEvent {
  final String tripId;
  final String removeUserId;
  @override
  String toString() => 'LeaveTripEvent';

  LeaveTripEvent(this.tripId, this.removeUserId);

  @override
  Stream<TripState> applyAsync({TripState currentState, TripBloc bloc}) async* {
    try {
      yield UnTripState(0);
      // load river
      var result =
          await _tripRepository.removeTripParticipant(tripId, removeUserId);
      yield LeavedTripState(0, newLogId: result);
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LeaveTripEvent', error: _, stackTrace: stackTrace);
      yield ErrorTripState(0, _?.toString());
    }
  }
}
