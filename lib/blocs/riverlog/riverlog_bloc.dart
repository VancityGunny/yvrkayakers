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
  final String _selectedUserId;

  RiverlogBloc(this._selectedUserId);
  StreamController allRiverlogController;
  final BehaviorSubject<List<RiverlogShortModel>> allRiverlogs =
      BehaviorSubject<List<RiverlogShortModel>>();

  initStream() {
    allRiverlogController = StreamController.broadcast();

    allRiverlogController.addStream(FirebaseFirestore.instance
        .collection('/riverlogs')
        .doc(_selectedUserId)
        .snapshots());
    allRiverlogController.stream.listen((event) {
      DocumentSnapshot docSnapshot = event;
      var newRiverlogs = new List<RiverlogShortModel>();
      if (docSnapshot.exists) {
        var foundUserLogs = UserRiverlogModel.fromFire(docSnapshot);
        newRiverlogs = foundUserLogs.logSummary;
      }
      allRiverlogs.add(newRiverlogs);
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
