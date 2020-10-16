import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';

class RiverbetaAddScreen extends StatefulWidget {
  @override
  RiverbetaAddScreenState createState() {
    return RiverbetaAddScreenState();
  }
}

class RiverbetaAddScreenState extends State<RiverbetaAddScreen> {
  RiverbetaAddScreenState();
  LocationResult _pickedLocation;
  TextEditingController txtNewSectionName = TextEditingController();
  TextEditingController txtNewRiverName = TextEditingController();
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
    return BlocBuilder<RiverbetaBloc, RiverbetaState>(builder: (
      BuildContext context,
      RiverbetaState currentState,
    ) {
      if (currentState is UnRiverbetaState) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      if (currentState is ErrorRiverbetaState) {
        return Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(currentState.errorMessage ?? 'Error'),
            Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: RaisedButton(
                color: Colors.blue,
                child: Text('reload'),
                onPressed: _load,
              ),
            ),
          ],
        ));
      }
      if (currentState is InRiverbetaState) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(currentState.hello),
              Text('Flutter files: done'),
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: RaisedButton(
                  color: Colors.red,
                  child: Text('throw error'),
                  onPressed: () => _load(true),
                ),
              ),
            ],
          ),
        );
      }
      return newRiverForm(context);
    });
  }

  void _load([bool isError = false]) {
    //widget._riverbetaBloc.add(LoadRiverbetaEvent(isError));
  }

  Widget newRiverForm(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text('Add New River'),
          Row(children: <Widget>[
            Text('River Name:'),
            Expanded(
              child: TextField(
                controller: this.txtNewRiverName,
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: "River Name?"),
              ),
            )
          ]),
          Row(children: <Widget>[
            Text('Section Name:'),
            Expanded(
              child: TextField(
                controller: this.txtNewSectionName,
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: "River Section Name?"),
              ),
            )
          ]),
          Row(children: <Widget>[
            Text('PutIn:'),
            RaisedButton(
              onPressed: () async {
                LocationResult result = await showLocationPicker(
                  context, DotEnv().env['GOOGLE_MAP_API'],
                  initialCenter: LatLng(31.1975844, 29.9598339),
//                      automaticallyAnimateToCurrentLocation: true,
//                      mapStylePath: 'assets/mapStyle.json',
                  myLocationButtonEnabled: true,
                  // requiredGPS: true,
                  layersButtonEnabled: true,
                  // countries: ['AE', 'NG']

//                      resultCardAlignment: Alignment.bottomCenter,
                  //desiredAccuracy: LocationAccuracy.best,
                );
                print("result = $result");
                setState(() => _pickedLocation = result);
              },
              child: Text('Pick location'),
            ),
            Text((_pickedLocation == null)
                ? 'Please select location'
                : _pickedLocation.latLng.latitude.toString() +
                    ',' +
                    _pickedLocation.latLng.longitude.toString()),
          ]),
          Row(children: <Widget>[
            Text('TakeOut:'),
            Expanded(
              child: TextField(
                controller: this.txtNewSectionName,
                decoration:
                    InputDecoration(border: InputBorder.none, hintText: "Lat?"),
              ),
            ),
            Expanded(
              child: TextField(
                controller: this.txtNewSectionName,
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: "Long?"),
              ),
            )
          ]),
          Expanded(
            flex: 1,
            child: Container(
              child: OutlineButton(
                child: Text('Add Image'),
                onPressed: uploadImage,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void uploadImage() {}
}
