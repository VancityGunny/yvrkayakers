import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';
import 'package:yvrkayakers/blocs/riverlog/index.dart';
import 'package:yvrkayakers/blocs/riverlog/riverlog_add_page.dart';

class RiverbetaDetailPage extends StatefulWidget {
  RiverbetaModel _foundRiver;
  RiverbetaDetailPage(this._foundRiver);
  @override
  RiverbetaDetailPageState createState() {
    return RiverbetaDetailPageState();
  }
}

class RiverbetaDetailPageState extends State<RiverbetaDetailPage> {
  RiverbetaDetailPageState();

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
    return BlocBuilder<RiverbetaBloc, RiverbetaState>(builder: (
      BuildContext context,
      RiverbetaState currentState,
    ) {
      if (currentState is UnRiverbetaState) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      if (currentState is ErrorRiverbetaState) {
        return SingleChildScrollView(
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
      if (currentState is InRiverbetaState) {
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
      return Scaffold(
          appBar: AppBar(
            title: Text(widget._foundRiver.riverName),
          ),
          body: Column(
            children: [
              Text(widget._foundRiver.riverName,
                  style: TextStyle(fontSize: 20.0)),
              Text(widget._foundRiver.sectionName),
              Text('Difficulty: ' + widget._foundRiver.difficulty.toString()),
              Text('Level: ' +
                  widget._foundRiver.minFlow.toString() +
                  ' to ' +
                  widget._foundRiver.maxFlow.toString() +
                  ' ' +
                  widget._foundRiver.gaugeUnit),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                RaisedButton(
                  onPressed: () {
                    goToAddRiverLogPage();
                  },
                  child: Text("Add New Log"),
                ),
                RaisedButton(
                  onPressed: () {},
                  child: Text("Make New Trip"),
                )
              ])
            ],
          ));
    });
  }

  void _load([bool isError = false]) {
    //widget._riverbetaBloc.add(LoadRiverbetaEvent(isError));
  }

  void goToAddRiverLogPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) {
        return MultiBlocProvider(providers: [
          BlocProvider.value(
            value: BlocProvider.of<RiverlogBloc>(context),
          ),
          BlocProvider.value(
            value: BlocProvider.of<RiverbetaBloc>(context),
          ),
        ], child: RiverlogAddPage(widget._foundRiver));
      }),
    );
  }
}
