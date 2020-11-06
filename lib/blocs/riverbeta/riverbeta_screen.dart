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

              return LimitedBox(
                  maxHeight: 300,
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        var curRiver = snapshot.data[index];
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
                                                    riverIcon(curRiver),
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
                      }));
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
        ], child: RiverbetaDetailPage(curRiver));
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

  Widget riverIcon(RiverbetaModel curRiver) {
    return Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
                alignment: Alignment.center,
                height: 60.0,
                width: 60.0,
                decoration: new BoxDecoration(
                    color: Colors.black87,
                    borderRadius: new BorderRadius.circular(10.0)),
                child: Text(
                  CommonFunctions.translateRiverDifficulty(curRiver.difficulty),
                  style: TextStyle(fontSize: 40, color: Colors.amber),
                ))));
  }

  Widget riverNameSymbol(RiverbetaModel curRiver) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: curRiver.riverName,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
          children: <TextSpan>[
            TextSpan(
                text: '\n${curRiver.sectionName}',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
