import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yvrkayakers/blocs/riverlog/index.dart';
import 'package:yvrkayakers/widgets/widgets.dart';
import 'package:intl/intl.dart';

class RiverlogDetailPage extends StatefulWidget {
  final String _selectedUserId;
  final String _selectedRiverlogId;
  RiverlogDetailPage(this._selectedUserId, this._selectedRiverlogId);
  @override
  RiverbetaDetailPageState createState() {
    return RiverbetaDetailPageState();
  }
}

class RiverbetaDetailPageState extends State<RiverlogDetailPage> {
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
    return BlocBuilder<RiverlogBloc, RiverlogState>(builder: (
      BuildContext context,
      RiverlogState currentState,
    ) {
      if (currentState is UnRiverlogState) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      if (currentState is ErrorRiverlogState) {
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
      if (currentState is FoundRiverlogState) {
        var foundRiverlog = currentState.foundRiverlog;
        var foundRiverlogHashtag = currentState.foundRiverlogHashtag;
        return Scaffold(
            appBar: AppBar(
              title: Text(
                  '${foundRiverlog.river.riverName} - ${DateFormat.yMMMd().format(foundRiverlog.logDateStart)}'),
            ),
            body: SingleChildScrollView(
                child: Column(children: [
              UserExperienceCard(),
              Text(foundRiverlogHashtag.hashtag),
              Text(foundRiverlog.note ?? '')
            ])));
      }
    });
  }

  void _load([bool isError = false]) {
    //widget._riverbetaBloc.add(LoadRiverbetaEvent(isError));

    BlocProvider.of<RiverlogBloc>(context).add(FetchingRiverlogEvent(
        this.widget._selectedUserId, this.widget._selectedRiverlogId));
  }
}
