import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';
import 'package:yvrkayakers/blocs/riverbeta/riverbeta_add_page.dart';
import 'package:yvrkayakers/blocs/riverbeta/riverbeta_detail_page.dart';
import 'package:yvrkayakers/common/common_functions.dart';

/// Screen that show all river list
class RiverbetaScreen extends StatefulWidget {
  @override
  RiverbetaScreenState createState() {
    return RiverbetaScreenState();
  }
}

class RiverbetaScreenState extends State<RiverbetaScreen> {
  List<bool> _gradeSelections = List.generate(4, (_) => false);
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
        Text('Rivers Info'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('Near'),
            DropdownButton(
              items: [
                DropdownMenuItem(
                  child: Text('Vancouver, BC'),
                )
              ],
              onChanged: (value) {},
            )
          ],
        ),
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
                });
              },
            ),
          ],
        ),
        RaisedButton(
          onPressed: () {
            goToAddRiverPage();
          },
          child: Text('Add River Beta'),
        ),
        RaisedButton(
          color: Colors.white,
          onPressed: () {
            location.getLocation().then((value) {
              var myLocation = GeoFirePoint(value.latitude, value.longitude);
              BlocProvider.of<RiverbetaBloc>(context)
                  .add(SearchingNearbyRiverbetaEvent(myLocation, 10.0));
            });
          },
          child: Icon(FontAwesomeIcons.search, color: Colors.black),
        ),
        BlocBuilder<RiverbetaBloc, RiverbetaState>(
            bloc: BlocProvider.of<RiverbetaBloc>(context),
            builder: (
              BuildContext context,
              RiverbetaState currentState,
            ) {
              if (currentState is FoundNearbyRiverbetaState) {
                if (currentState.foundRivers.length == 0) {
                  return Center(
                    child: Text('Found No Rivers'),
                  );
                }

                return LimitedBox(
                    maxHeight: 300,
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: currentState.foundRivers.length,
                        itemBuilder: (context, index) {
                          var curRiver = currentState.foundRivers[index];
                          return GestureDetector(
                              onTap: () {
                                goToRiverDetail(curRiver);
                              },
                              child: Row(
                                children: [
                                  ClipOval(
                                    child: Material(
                                      color: Colors.blue, // button color
                                      child: InkWell(
                                        splashColor:
                                            Colors.red, // inkwell color
                                        child: SizedBox(
                                            width: 35,
                                            height: 35,
                                            child: Text(
                                              CommonFunctions
                                                  .translateRiverDifficulty(
                                                      currentState
                                                          .foundRivers[index]
                                                          .difficulty),
                                              style: TextStyle(fontSize: 15.0),
                                              textAlign: TextAlign.center,
                                            )),
                                        onTap: () {},
                                      ),
                                    ),
                                  ),
                                  Text(currentState
                                      .foundRivers[index].riverName),
                                  Text(currentState
                                      .foundRivers[index].sectionName),
                                ],
                              ));
                        }));
              }
              // default loading
              return Center(
                child: CircularProgressIndicator(),
              );
            })
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
          BlocProvider<RiverbetaBloc>(
            create: (BuildContext context) =>
                BlocProvider.of<RiverbetaBloc>(context),
          ),
        ], child: RiverbetaDetailPage(curRiver));
      }),
    );
  }

  void goToAddRiverPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) {
        return MultiBlocProvider(providers: [
          BlocProvider<RiverbetaBloc>(
            create: (BuildContext context) =>
                BlocProvider.of<RiverbetaBloc>(context),
          ),
        ], child: RiverbetaAddPage());
      }),
    );
  }
}
