import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yvrkayakers/blocs/riverlog/index.dart';

class RiverlogScreen extends StatefulWidget {
  const RiverlogScreen({
    Key key,
    @required RiverlogBloc riverlogBloc,
  })  : _riverlogBloc = riverlogBloc,
        super(key: key);

  final RiverlogBloc _riverlogBloc;

  @override
  RiverlogScreenState createState() {
    return RiverlogScreenState();
  }
}

class RiverlogScreenState extends State<RiverlogScreen> {
  RiverlogScreenState();

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
    return BlocBuilder<RiverlogBloc, RiverlogState>(
        bloc: widget._riverlogBloc,
        builder: (
          BuildContext context,
          RiverlogState currentState,
        ) {
          if (currentState is UnRiverlogState) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (currentState is ErrorRiverlogState) {
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
          if (currentState is InRiverlogState) {
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
    widget._riverlogBloc.add(LoadRiverlogEvent(isError));
  }
}
