import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';
import 'package:yvrkayakers/common/common_functions.dart';
import 'package:yvrkayakers/common/myconstants.dart';

class RiverbetaAddPage extends StatefulWidget {
  @override
  RiverbetaAddPageState createState() {
    return RiverbetaAddPageState();
  }
}

class RiverbetaAddPageState extends State<RiverbetaAddPage> {
  double _riverGrade = 2.0;
  String _riverGradeLabel = 'II';

  String _selectedCountry, _selectedState, _selectedCity = null;
  LocationResult _putInLocation;
  LocationResult _takeOutLocation;
  String _riverGaugeUnit = 'Gauge';
  TextEditingController txtNewSectionName = TextEditingController();
  TextEditingController txtNewRiverName = TextEditingController();
  TextEditingController txtRiverMin = TextEditingController();
  TextEditingController txtRiverMax = TextEditingController();
  TextEditingController txtLevelIncrement = TextEditingController();

  RiverbetaAddPageState();
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
    return Scaffold(
        appBar: AppBar(
          title: Text("Suggest New River"),
        ),
        body: newRiverForm(context));
  }

  void _load([bool isError = false]) {
    //widget._riverbetaBloc.add(LoadRiverbetaEvent(isError));
  }

  Widget newRiverForm(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Row(children: <Widget>[
            Expanded(
              child: TextField(
                controller: this.txtNewRiverName,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "<<River Name>>",
                    labelText: "River Name:"),
              ),
            )
          ]),
          Row(children: <Widget>[
            Expanded(
              child: TextField(
                controller: this.txtNewSectionName,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "<<Section Name>>, Leave Blank for Main Section",
                    labelText: "Section Name:"),
              ),
            ),
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Grade'),
              RaisedButton(
                child: Text(_riverGradeLabel, style: TextStyle(fontSize: 20.0)),
                onPressed: () {
                  showMaterialScrollPicker(
                    context: context,
                    title: "Pick River Grade",
                    items: MyConstants.RIVER_GRADES_LABELS,
                    selectedItem: _riverGradeLabel,
                    onChanged: (value) => setState(() {
                      _riverGrade =
                          CommonFunctions.getRiverDifficultyFromLabel(value);
                      _riverGradeLabel = value;
                    }),
                  );
                },
              ),
            ],
          ),
          Row(children: <Widget>[
            Text('River Range:'),
            Expanded(
              child: TextField(
                controller: this.txtRiverMin,
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: "River Min?"),
              ),
            ),
            Expanded(
              child: TextField(
                controller: this.txtRiverMax,
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: "River Max?"),
              ),
            ),
            Expanded(
              child: TextField(
                controller: this.txtLevelIncrement,
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: "Increment"),
              ),
            ),
            DropdownButton(
              value: _riverGaugeUnit,
              items: [
                DropdownMenuItem(
                  value: 'CMS',
                  child: Text('CMS'),
                ),
                DropdownMenuItem(
                  value: 'M',
                  child: Text('M'),
                ),
                DropdownMenuItem(
                  value: 'Gauge',
                  child: Text('Visual Gauge'),
                )
              ],
              onChanged: (value) {
                setState(() {
                  _riverGaugeUnit = value;
                });
              },
            )
          ]),
          Row(
            children: [
              Text('Location'),
              RaisedButton(
                child: Text('${_selectedState} - ${_selectedCountry}'),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(builder: (context, setState) {
                          return AlertDialog(
                            title: Text('Enter City'),
                            content: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SelectState(
                                    onCountryChanged: (value) {
                                      setState(() {
                                        _selectedCountry = value;
                                      });
                                    },
                                    onStateChanged: (value) {
                                      setState(() {
                                        _selectedState = value;
                                      });
                                    },
                                    onCityChanged: (value) {
                                      setState(() {
                                        _selectedCity = value;
                                      });
                                    },
                                  ),
                                ]),
                            actions: <Widget>[
                              FlatButton(
                                onPressed: () {
                                  //selectThisCity();
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                },
                                child: Text('Yes'),
                              ),
                              FlatButton(
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                },
                                child: Text('No'),
                              ),
                            ],
                          );
                        });
                      },
                      barrierDismissible: false);
                },
              )
            ],
          ),
          Row(children: <Widget>[
            Text('PutIn:'),
            Text((_putInLocation == null)
                ? '<<EMPTY>>'
                : _putInLocation.latLng.latitude.toString().substring(0, 8) +
                    ',' +
                    _putInLocation.latLng.longitude.toString().substring(0, 8)),
            RaisedButton(
              onPressed: () async {
                LocationResult result = await showLocationPicker(
                    context, DotEnv().env['GOOGLE_MAP_API'],
                    //initialCenter: LatLng(31.1975844, 29.9598339),
//                      automaticallyAnimateToCurrentLocation: true,
//                      mapStylePath: 'assets/mapStyle.json',
                    myLocationButtonEnabled: true,
                    // requiredGPS: true,
                    layersButtonEnabled: true,
                    countries: ['CA', 'US']
//                      resultCardAlignment: Alignment.bottomCenter,
                    //desiredAccuracy: LocationAccuracy.best,
                    );
                print("result = $result");

                setState(() => _putInLocation = result);
              },
              child: Text('Pick location'),
            ),
          ]),
          Row(children: <Widget>[
            Text('TakeOut:'),
            Text((_takeOutLocation == null)
                ? '<<EMPTY>>'
                : _takeOutLocation.latLng.latitude.toString().substring(0, 8) +
                    ',' +
                    _takeOutLocation.latLng.longitude
                        .toString()
                        .substring(0, 8)),
            RaisedButton(
              onPressed: () async {
                LocationResult result = await showLocationPicker(
                  context,
                  DotEnv().env['GOOGLE_MAP_API'],
                  myLocationButtonEnabled: true,
                  layersButtonEnabled: true,
                );
                print("result = $result");
                setState(() => _takeOutLocation = result);
              },
              child: Text('Pick location'),
            ),
          ]),
          RaisedButton(
              child: Text('Suggest New River'),
              onPressed: () {
                addNewRiver(context); // go up one level
              })
        ],
      ),
    );
  }

  void addNewRiver(BuildContext context) {
    var uuid = new Uuid();
    var riverId = uuid.v1();
    RiverbetaModel newRiver = RiverbetaModel(
        riverId.toString(),
        txtNewRiverName.text,
        txtNewSectionName.text,
        _riverGrade,
        null, //GeoFirePoint(_putInLocation.latLng.latitude, _putInLocation.latLng.longitude),
        null, //GeoFirePoint(_takeOutLocation.latLng.latitude, _takeOutLocation.latLng.longitude),
        (txtRiverMin.text == "") ? null : double.parse(txtRiverMin.text),
        (txtRiverMax.text == "") ? null : double.parse(txtRiverMax.text),
        _riverGaugeUnit,
        (txtLevelIncrement.text == "")
            ? null
            : double.parse(txtLevelIncrement.text));
    // add new river
    BlocProvider.of<RiverbetaBloc>(context).add(AddingRiverbetaEvent(newRiver));
    Navigator.of(context).pop(); // go up one level
  }
}
