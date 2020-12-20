import 'dart:async';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yvrkayakers/blocs/trip/index.dart';
import 'package:yvrkayakers/common/common_functions.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  // todo: check singleton for logic in project
  // use GetIt for DI in projct
  @override
  TripState get initialState => UnTripState(0);

  StreamController newTripController;
  StreamController pastTripController;

  final BehaviorSubject<List<TripModel>> allNewTrips =
      BehaviorSubject<List<TripModel>>();

  final BehaviorSubject<List<TripModel>> pastParticipatedTrips =
      BehaviorSubject<List<TripModel>>();

  initStream() {
    newTripController = StreamController.broadcast();
    newTripController.addStream(FirebaseFirestore.instance
        .collection('/trips')
        .where('tripDate', isGreaterThan: CommonFunctions.getTripLockDateTime())
        .orderBy('tripDate')
        .snapshots());
    newTripController.stream.listen((event) {
      QuerySnapshot querySnapshot = event;
      var newTrips = new List<TripModel>();
      if (querySnapshot.docs.length > 0) {
        event.docs.forEach((f) {
          newTrips.add(TripModel.fromFire(f));
        });
      }
      allNewTrips.add(newTrips);
    });

    pastTripController = StreamController.broadcast();
    pastTripController.addStream(FirebaseFirestore.instance
        .collection('/trips')
        .where('tripDate', isLessThan: CommonFunctions.getTripLockDateTime())
        .where('participantIds',
            arrayContainsAny: [FirebaseAuth.instance.currentUser.uid])
        .orderBy('tripDate', descending: true)
        .snapshots());
    pastTripController.stream.listen((event) {
      QuerySnapshot querySnapshot = event;
      var tempTrips = new List<TripModel>();
      if (querySnapshot.docs.length > 0) {
        event.docs.forEach((f) {
          tempTrips.add(TripModel.fromFire(f));
        });
      }
      pastParticipatedTrips.add(tempTrips);
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
