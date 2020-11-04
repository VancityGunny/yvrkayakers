import 'package:flutter/material.dart';
import 'package:yvrkayakers/blocs/trip/index.dart';

class TripPage extends StatefulWidget {
  static const String routeName = '/trip';

  @override
  _TripPageState createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  final _tripBloc = TripBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip'),
      ),
      body: TripScreen(tripBloc: _tripBloc),
    );
  }
}
