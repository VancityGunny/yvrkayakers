import 'package:flutter/material.dart';
import 'package:yvrkayakers/blocs/trip/index.dart';

class TripPage extends StatefulWidget {
  static const String routeName = '/trip';

  @override
  _TripPageState createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  final _tripBloc = TripBloc();
  bool _showPast = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trip'), actions: <Widget>[
        Text('Show Past Trip'),
        Switch(
          value: _showPast,
          activeColor: Colors.greenAccent,
          onChanged: (value) {
            setState(() {
              _showPast = !_showPast;
            });
          },
        )
      ]),
      body: (_showPast == true)
          ? PastTripScreen(tripBloc: _tripBloc)
          : TripScreen(tripBloc: _tripBloc),
    );
  }
}
