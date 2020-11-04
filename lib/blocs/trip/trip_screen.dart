import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yvrkayakers/blocs/trip/index.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({
    Key key,
    @required TripBloc tripBloc,
  })  : _tripBloc = tripBloc,
        super(key: key);

  final TripBloc _tripBloc;

  @override
  TripScreenState createState() {
    return TripScreenState();
  }
}

class TripScreenState extends State<TripScreen> {
  TripScreenState();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripBloc, TripState>(
        bloc: widget._tripBloc,
        builder: (
          BuildContext context,
          TripState currentState,
        ) {
          if (currentState is UnTripState) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (currentState is ErrorTripState) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(currentState.errorMessage ?? 'Error'),
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: RaisedButton(
                    color: Colors.blue,
                    child: Text('reload'),
                    onPressed: _load,
                  ),
                ),
              ],
            ));
          }
          if (currentState is InTripState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(currentState.hello),
                  Text('Flutter files: done'),
                  Padding(
                    padding: const EdgeInsets.only(top: 32.0),
                    child: RaisedButton(
                      color: Colors.red,
                      child: Text('throw error'),
                      onPressed: () => _load(true),
                    ),
                  ),
                ],
              ),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  void _load([bool isError = false]) {
    widget._tripBloc.add(LoadTripEvent(isError));
  }
}
