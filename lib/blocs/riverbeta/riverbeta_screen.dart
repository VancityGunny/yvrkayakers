import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';

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
                if (currentState.foundRivers.length > 0) {
                  return Center(
                    child: Text('Found Rivers'),
                  );
                } else {
                  return Center(
                    child: Text('Found No Rivers'),
                  );
                }
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
}
