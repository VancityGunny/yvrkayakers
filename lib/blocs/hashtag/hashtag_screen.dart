import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yvrkayakers/blocs/hashtag/index.dart';

class HashtagScreen extends StatefulWidget {
  const HashtagScreen({
    Key key,
    @required HashtagBloc hashtagBloc,
  })  : _hashtagBloc = hashtagBloc,
        super(key: key);

  final HashtagBloc _hashtagBloc;

  @override
  HashtagScreenState createState() {
    return HashtagScreenState();
  }
}

class HashtagScreenState extends State<HashtagScreen> {
  HashtagScreenState();

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
    return BlocBuilder<HashtagBloc, HashtagState>(
        bloc: widget._hashtagBloc,
        builder: (
          BuildContext context,
          HashtagState currentState,
        ) {
          if (currentState is UnHashtagState) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (currentState is ErrorHashtagState) {
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
          if (currentState is InHashtagState) {
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
    widget._hashtagBloc.add(LoadHashtagEvent(isError));
  }
}
