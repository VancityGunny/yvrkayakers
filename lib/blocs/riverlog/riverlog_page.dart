import 'package:flutter/material.dart';
import 'package:yvrkayakers/blocs/riverlog/index.dart';

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
        title: Text('My Logbook'),
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
