import 'dart:async';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_session/flutter_session.dart';
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
    var session = FlutterSession();
    session.get("currentUserId").then((value) {
      riverLogController.addStream(FirebaseFirestore.instance
          .collection('/riverlogs')
          .doc(value)
          .collection('/logs')
          .snapshots());
      riverLogController.stream.listen((event) {
        QuerySnapshot querySnapshot = event;
        if (querySnapshot.docs.length > 0) {
          var newRiverlogs = new List<RiverlogModel>();
          event.docs.forEach((f) {
            newRiverlogs.add(RiverlogModel.fromFire(f));
          });
          allRiverLogs.add(newRiverlogs);
        }
      });
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
