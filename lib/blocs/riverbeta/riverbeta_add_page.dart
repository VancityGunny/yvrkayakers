import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';
import 'package:yvrkayakers/common/common_functions.dart';

class RiverbetaAddPage extends StatefulWidget {
  @override
  RiverbetaAddPageState createState() {
    return RiverbetaAddPageState();
  }
}

class RiverbetaAddPageState extends State<RiverbetaAddPage> {
  double _riverGrade = 2.0;
  String _riverGradeLabel = 'II';
  LocationResult _putInLocation;
  LocationResult _takeOutLocation;
  String _riverGaugeUnit = 'Visual';
  TextEditingController txtNewSectionName = TextEditingController();
  TextEditingController txtNewRiverName = TextEditingController();
  TextEditingController txtRiverMin = TextEditingController();
  TextEditingController txtRiverMax = TextEditingController();

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
          title: Text("Add New River"),
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
          Text('Add New River'),
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
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.red[700],
                  inactiveTrackColor: Colors.red[100],
                  trackShape: RoundedRectSliderTrackShape(),
                  trackHeight: 4.0,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                  thumbColor: Colors.redAccent,
                  overlayColor: Colors.red.withAlpha(32),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
                  tickMarkShape: RoundSliderTickMarkShape(),
                  activeTickMarkColor: Colors.red[700],
                  inactiveTickMarkColor: Colors.red[100],
                  valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                  valueIndicatorColor: Colors.redAccent,
                  valueIndicatorTextStyle: TextStyle(
                    color: Colors.white,
                  ),
                ),
                child: Slider(
                  value: _riverGrade,
                  min: 2.0,
                  max: 5.0,
                  divisions: 6,
                  label: '$_riverGradeLabel',
                  onChanged: (value) {
                    setState(
                      () {
                        _riverGradeLabel =
                            CommonFunctions.translateRiverDifficulty(value);
                        _riverGrade = value;
                      },
                    );
                  },
                ),
              ),
              Text('$_riverGradeLabel')
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
                  value: 'Visual',
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
              child: Text('Add New River'),
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
        GeoFirePoint(
            _putInLocation.latLng.latitude, _putInLocation.latLng.longitude),
        GeoFirePoint(_takeOutLocation.latLng.latitude,
            _takeOutLocation.latLng.longitude),
        double.parse(txtRiverMin.text),
        double.parse(txtRiverMax.text),
        _riverGaugeUnit);
    // add new river
    BlocProvider.of<RiverbetaBloc>(context).add(AddingRiverbetaEvent(newRiver));
    Navigator.of(context).pop(); // go up one level
  }
}
