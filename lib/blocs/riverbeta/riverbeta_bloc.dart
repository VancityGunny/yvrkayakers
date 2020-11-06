import 'dart:async';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';
import 'package:yvrkayakers/common/common_functions.dart';

class RiverbetaBloc extends Bloc<RiverbetaEvent, RiverbetaState> {
  @override
  RiverbetaState get initialState => UnRiverbetaState(0);
  static final _firestore = FirebaseFirestore.instance;
  static final Geoflutterfire geo = Geoflutterfire();

  StreamController riverBetaController;
  final BehaviorSubject<List<RiverbetaModel>> allRiverbetas =
      BehaviorSubject<List<RiverbetaModel>>();

  initStream() {
    riverBetaController = StreamController.broadcast();

    CommonFunctions.getCurrentLocation().then((currentLocation) {
      var collectionReference = _firestore.collection('riverbetas');
      double radius = 50; //50; //kilometer
      String field = 'putInLocation';
      riverBetaController.addStream(geo
          .collection(collectionRef: collectionReference)
          .within(center: currentLocation, radius: radius, field: field));
      riverBetaController.stream.listen((event) {
        List<DocumentSnapshot> result = event;
        if (result.length > 0) {
          var newRiverbetas = new List<RiverbetaModel>();
          result.forEach((element) {
            newRiverbetas.add(RiverbetaModel.fromFire(element));
          });
          allRiverbetas.add(newRiverbetas);
        }
      });
    });
  }

  final RiverbetaRepository riverbetaRepository = new RiverbetaRepository();

  @override
  Stream<RiverbetaState> mapEventToState(
    RiverbetaEvent event,
  ) async* {
    try {
      yield* event.applyAsync(currentState: state, bloc: this);
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'RiverbetaBloc', error: _, stackTrace: stackTrace);
      yield state;
    }
  }
}
