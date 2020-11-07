import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';
import 'package:yvrkayakers/blocs/riverlog/index.dart';
import 'package:yvrkayakers/blocs/riverlog/riverlog_add_page.dart';

class RiverlogPage extends StatefulWidget {
  static const String routeName = '/riverlog';

  @override
  _RiverlogPageState createState() => _RiverlogPageState();
}

class _RiverlogPageState extends State<RiverlogPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riverlog'),
      ),
      body: RiverlogScreen(),
      // floatingActionButton: new Visibility(
      //     child: FloatingActionButton(
      //         child: Icon(Icons.add), onPressed: goToAddRiverLogPage)),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void goToAddRiverLogPage() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (BuildContext context) {
    //     return MultiBlocProvider(providers: [
    //       BlocProvider.value(
    //         value: BlocProvider.of<RiverlogBloc>(context),
    //       ),
    //       BlocProvider.value(
    //         value: BlocProvider.of<RiverbetaBloc>(context),
    //       ),
    //     ], child: RiverlogAddPage());
    //   }),
    // );
  }
}
