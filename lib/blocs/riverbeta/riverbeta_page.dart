import 'package:flutter/material.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';

class RiverbetaPage extends StatefulWidget {
  static const String routeName = '/riverbeta';

  @override
  _RiverbetaPageState createState() => _RiverbetaPageState();
}

class _RiverbetaPageState extends State<RiverbetaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riverbeta'),
      ),
      body: RiverbetaScreen(),
    );
  }
}
