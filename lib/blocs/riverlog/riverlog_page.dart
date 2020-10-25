import 'package:flutter/material.dart';
import 'package:yvrkayakers/blocs/riverlog/index.dart';

class RiverlogPage extends StatefulWidget {
  static const String routeName = '/riverlog';

  @override
  _RiverlogPageState createState() => _RiverlogPageState();
}

class _RiverlogPageState extends State<RiverlogPage> {
  final _riverlogBloc = RiverlogBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riverlog'),
      ),
      body: RiverlogScreen(riverlogBloc: _riverlogBloc),
    );
  }
}
