import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';
import 'package:yvrkayakers/blocs/riverbeta/riverbeta_add_page.dart';
import 'package:yvrkayakers/blocs/riverbeta/riverbeta_detail_page.dart';
import 'package:yvrkayakers/common/common_functions.dart';

import 'package:yvrkayakers/widgets/widgets.dart';

/// Screen that show all river list
class RiverbetaScreen extends StatefulWidget {
  @override
  RiverbetaScreenState createState() {
    return RiverbetaScreenState();
  }
}

class RiverbetaScreenState extends State<RiverbetaScreen> {
  List<bool> _gradeSelections = List.generate(4, (_) => true);
  List<double> _selectedGrades = [2.0, 3.0, 4.0, 5.0];
  Location location = new Location();
  RiverbetaScreenState();

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
        child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('Grade'),
            ToggleButtons(
              isSelected: _gradeSelections,
              children: [Text('II'), Text('III'), Text('IV'), Text('V')],
              onPressed: (index) {
                setState(() {
                  _gradeSelections[index] = !_gradeSelections[index];
                  _selectedGrades.clear();
                  for (var i = 0; i < _gradeSelections.length; i++) {
                    if (_gradeSelections[i] == true) {
                      _selectedGrades.add(i + 2.0); // we start from grade 2
                    }
                  }
                });
              },
            ),
          ],
        ),
        StreamBuilder(
            stream:
                BlocProvider.of<RiverbetaBloc>(context).allRiverbetas.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.data.length == 0) {
                return Container(
                    alignment: Alignment.center,
                    child: FaIcon(FontAwesomeIcons.userPlus,
                        size: 150, color: Color.fromARGB(15, 0, 0, 0)));
              }
              //filter data here
              List<RiverbetaModel> allRivers = snapshot.data;
              var allRiverCount = allRivers.length;
              var filteredRiverCount = allRivers
                  .where((element) => _selectedGrades
                      .contains(element.difficulty.roundToDouble()))
                  .toList()
                  .length;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Showing " +
                      filteredRiverCount.toString() +
                      " of " +
                      allRiverCount.toString() +
                      " rivers"),
                  RaisedButton(
                    onPressed: () {
                      goToAddRiverPage();
                    },
                    child: Text('Add River Beta'),
                  ),
                ],
              );
            }),
        StreamBuilder(
            stream:
                BlocProvider.of<RiverbetaBloc>(context).allRiverbetas.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.data.length == 0) {
                return Container(
                    alignment: Alignment.center,
                    child: FaIcon(FontAwesomeIcons.userPlus,
                        size: 150, color: Color.fromARGB(15, 0, 0, 0)));
              }

              //filter data here
              List<RiverbetaModel> allRivers = snapshot.data;
              var filteredRivers = allRivers
                  .where((element) => _selectedGrades
                      .contains(element.difficulty.roundToDouble()))
                  .toList();
              filteredRivers.sort((a, b) => a.riverName.compareTo(b.riverName));
              // filteredRivers.where((element) {
              //   element.difficulty
              // });
              return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: filteredRivers.length,
                  itemBuilder: (context, index) {
                    var curRiver = filteredRivers[index];
                    return GestureDetector(
                        onTap: () {
                          goToRiverDetail(curRiver);
                        },
                        child: Card(
                          elevation: 5,
                          child: Padding(
                            padding: EdgeInsets.all(7),
                            child: Stack(children: <Widget>[
                              Align(
                                alignment: Alignment.centerRight,
                                child: Stack(
                                  children: <Widget>[
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, top: 5),
                                        child: Column(
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                RiverGradeBadge(curRiver),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                riverNameSymbol(curRiver)
                                              ],
                                            )
                                          ],
                                        ))
                                  ],
                                ),
                              )
                            ]),
                          ),
                        ));
                  });
            }),
      ],
    ));
  }

  void _load([bool isError = false]) {
    // load nearby river first
    // default to selected location, within 10 km
    location.getLocation().then((value) {
      var myLocation = GeoFirePoint(value.latitude, value.longitude);
      BlocProvider.of<RiverbetaBloc>(context)
          .add(SearchingNearbyRiverbetaEvent(myLocation, 10.0));
    });
  }

  void addNewRiver() {}

  void goToRiverDetail(RiverbetaModel curRiver) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) {
        return MultiBlocProvider(providers: [
          BlocProvider<RiverbetaBloc>.value(
            value: BlocProvider.of<RiverbetaBloc>(context),
          ),
        ], child: RiverbetaDetailPage(curRiver.id));
      }),
    );
  }

  void goToAddRiverPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) {
        return MultiBlocProvider(providers: [
          BlocProvider<RiverbetaBloc>.value(
            value: BlocProvider.of<RiverbetaBloc>(context),
          ),
        ], child: RiverbetaAddPage());
      }),
    );
  }

  Widget riverNameSymbol(RiverbetaModel curRiver) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: curRiver.riverName,
          style: Theme.of(context).textTheme.caption,
          children: <TextSpan>[
            TextSpan(
                text: '\n${curRiver.sectionName}',
                style: Theme.of(context).textTheme.subtitle1),
          ],
        ),
      ),
    );
  }
}
