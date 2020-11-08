import 'dart:async';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yvrkayakers/blocs/trip/index.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  // todo: check singleton for logic in project
  // use GetIt for DI in projct
  @override
  TripState get initialState => UnTripState(0);

  StreamController tripController;
  final BehaviorSubject<List<TripModel>> allTrips =
      BehaviorSubject<List<TripModel>>();

  initStream() {
    tripController = StreamController.broadcast();
    tripController
        .addStream(FirebaseFirestore.instance.collection('/trips').snapshots());
    tripController.stream.listen((event) {
      QuerySnapshot querySnapshot = event;
      var newTrips = new List<TripModel>();
      if (querySnapshot.docs.length > 0) {
        event.docs.forEach((f) {
          newTrips.add(TripModel.fromFire(f));
        });
      }
      allTrips.add(newTrips);
    });
  }

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
