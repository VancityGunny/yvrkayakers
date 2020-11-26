import 'dart:async';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yvrkayakers/blocs/riverlog/index.dart';

class RiverlogBloc extends Bloc<RiverlogEvent, RiverlogState> {
  @override
  RiverlogState get initialState => UnRiverlogState(0);

  StreamController riverLogController;
  final BehaviorSubject<List<RiverlogModel>> allRiverLogs =
      BehaviorSubject<List<RiverlogModel>>();

  initStream() {
    riverLogController = StreamController.broadcast();

    var currentUserId = FirebaseAuth.instance.currentUser.uid;
    riverLogController.addStream(FirebaseFirestore.instance
        .collection('/riverlogs')
        .doc(currentUserId)
        .collection('/logs')
        .snapshots());
    riverLogController.stream.listen((event) {
      QuerySnapshot querySnapshot = event;
      var newRiverlogs = new List<RiverlogModel>();
      if (querySnapshot.docs.length > 0) {
        event.docs.forEach((f) {
          newRiverlogs.add(RiverlogModel.fromFire(f));
        });
      }
      allRiverLogs.add(newRiverlogs);
    });
  }

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
