import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';
import 'package:yvrkayakers/blocs/riverlog/index.dart';
import 'package:yvrkayakers/blocs/riverlog/riverlog_add_page.dart';

class RiverlogScreen extends StatefulWidget {
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
    return SingleChildScrollView(
        child: Column(children: [
      Text('Rivers Logbook'),
      RaisedButton(
        onPressed: () {
          goToAddRiverLogPage();
        },
        child: Text('Add River Log'),
      ),
      BlocBuilder<RiverlogBloc, RiverlogState>(
          bloc: BlocProvider.of<RiverlogBloc>(context),
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
            if (currentState is LoadedUserRiverlogState) {
              return LimitedBox(
                  maxHeight: 300,
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: currentState.riverLogs.length,
                      itemBuilder: (context, index) {
                        var curRiver = currentState.riverLogs[index];
                        return Text("RiverID:" +
                            curRiver.riverbetaId +
                            ", Note:" +
                            curRiver.note);
                      }));
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          })
    ]));
  }

  void _load([bool isError = false]) {
    var session = FlutterSession();
    var currentUserId = session.get("currentUserId").toString();
    BlocProvider.of<RiverlogBloc>(context)
        .add(LoadUserRiverlogEvent(currentUserId));
  }

  void goToAddRiverLogPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) {
        return MultiBlocProvider(providers: [
          BlocProvider<RiverlogBloc>(
            create: (BuildContext context) =>
                BlocProvider.of<RiverlogBloc>(context),
          ),
          BlocProvider<RiverbetaBloc>(
            create: (BuildContext context) =>
                BlocProvider.of<RiverbetaBloc>(context),
          ),
        ], child: RiverlogAddPage());
      }),
    );
  }
}
