import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yvrkayakers/blocs/riverlog/index.dart';

class RiverlogAddPage extends StatefulWidget {
  @override
  RiverlogAddPageState createState() {
    return RiverlogAddPageState();
  }
}

class RiverlogAddPageState extends State<RiverlogAddPage> {
  RiverlogAddPageState();
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _load([bool isError = false]) {
    //widget._riverbetaBloc.add(LoadRiverbetaEvent(isError));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Log River Run"),
        ),
        body: BlocBuilder<RiverlogBloc, RiverlogState>(builder: (
          BuildContext context,
          RiverlogState currentState,
        ) {
          if (currentState is UnRiverlogState) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }
}
