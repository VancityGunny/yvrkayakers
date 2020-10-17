import 'dart:async';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';

class RiverbetaBloc extends Bloc<RiverbetaEvent, RiverbetaState> {
  @override
  RiverbetaState get initialState => UnRiverbetaState(0);

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
