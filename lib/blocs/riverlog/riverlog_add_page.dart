import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';
import 'package:yvrkayakers/blocs/riverlog/index.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RiverlogAddPage extends StatefulWidget {
  final RiverbetaModel _selectedRiver;

  @override
  RiverlogAddPage(this._selectedRiver);

  @override
  RiverlogAddPageState createState() {
    return RiverlogAddPageState();
  }
}

class RiverlogAddPageState extends State<RiverlogAddPage> {
  Location location = new Location();
  TextEditingController txtRiverName = TextEditingController();
  TextEditingController txtRiverLevel = TextEditingController();
  TextEditingController txtLogDate = TextEditingController();
  TextEditingController txtLogTimeIn = TextEditingController();
  TextEditingController txtLogTimeOut = TextEditingController();
  bool blnDidSwim = false;
  bool blnDidRescue = false;
  TextEditingController txtFriends = TextEditingController();
  DateTime _logDate;
  TimeOfDay _startTime;
  TimeOfDay _endTime;
  double _selectedWaterLevel;
  RiverlogAddPageState();
  @override
  void initState() {
    super.initState();
    _startTime =
        TimeOfDay(hour: 10, minute: 00); // default for user that dont log time
    _endTime = null;
    _logDate = DateTime.now();
    _load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _load([bool isError = false]) {
    //widget._riverbetaBloc.add(LoadRiverbetaEvent(isError));
    //Load RiverBeta list to dropdownbutton
    location.getLocation().then((value) {
      var myLocation = GeoFirePoint(value.latitude, value.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Log River Run"),
        ),
        body: newRiverLogForm());
  }

  Widget newRiverLogForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            widget._selectedRiver.riverName,
            style: Theme.of(context).textTheme.headline1,
          ),
          Row(
            children: [
              Flexible(
                flex: 4,
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                          "Log Date:${_logDate.year}/${_logDate.month}/${_logDate.day}",
                          style: Theme.of(context).textTheme.headline3),
                      onTap: pickLogDate,
                    ),
                    ListTile(
                        title: Text(
                            "Start: ${MaterialLocalizations.of(context).formatTimeOfDay(_startTime)}"),
                        onTap: pickStartTime),
                    ListTile(
                        title: Text((_endTime == null)
                            ? "<<No EndTime Selected>>"
                            : "End: ${MaterialLocalizations.of(context).formatTimeOfDay(_endTime)}"),
                        onTap: pickEndTime),
                  ],
                ),
              ),
              Flexible(
                  flex: 1,
                  child: Column(
                    children: [
                      (widget._selectedRiver.maxFlow == null)
                          ? Text('')
                          : RotatedBox(
                              quarterTurns: -1,
                              child: Slider(
                                min: widget._selectedRiver.minFlow,
                                max: widget._selectedRiver.maxFlow,
                                divisions: ((widget._selectedRiver.maxFlow -
                                        widget._selectedRiver.minFlow) ~/
                                    widget._selectedRiver.flowIncrement),
                                onChanged: (double value) {
                                  setState(() {
                                    _selectedWaterLevel = value;
                                  });
                                },
                                value: (_selectedWaterLevel == null)
                                    ? widget._selectedRiver.minFlow
                                    : _selectedWaterLevel,
                              )),
                      FaIcon(FontAwesomeIcons.water),
                      Text(
                        _selectedWaterLevel.toString(),
                        style: Theme.of(context).textTheme.headline3,
                      )
                    ],
                  ))
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: Checkbox(
                onChanged: (value) {
                  setState(() {
                    this.blnDidSwim = value;
                  });
                },
                value: blnDidSwim,
              )),
              Text('Swam?'),
              FaIcon(FontAwesomeIcons.swimmer)
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: Checkbox(
                onChanged: (value) {
                  setState(() {
                    this.blnDidRescue = value;
                  });
                },
                value: blnDidRescue,
              )),
              Text('Rescue?'),
              FaIcon(FontAwesomeIcons.lifeRing)
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: TextField(
                controller: this.txtFriends,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "<<Friends>>",
                    labelText: "Friends"),
              ))
            ],
          ),
          RaisedButton(
              child: Text('Add New Log'),
              onPressed: () {
                addNewRiverlog(context); // go up one level
              })
        ],
      ),
    );
  }

  void addNewRiverlog(BuildContext context) async {
    var currentUserId = FirebaseAuth.instance.currentUser.uid;
    var uuid = new Uuid();
    var logId = uuid.v1();
    RiverlogModel newRiverlog = RiverlogModel(
        logId,
        null,
        currentUserId,
        blnDidSwim,
        blnDidRescue,
        null,
        null,
        null,
        null,
        double.parse(txtRiverLevel.text), //waterlevel
        _logDate, //logdate
        null, //friends
        0, //totalround
        0, //riverround
        widget._selectedRiver.getRiverbetaShort());
    BlocProvider.of<RiverlogBloc>(context)
        .add(AddingRiverlogEvent(newRiverlog));
    Navigator.of(context).pop();
  }

  void pickStartTime() async {
    TimeOfDay t =
        await showTimePicker(context: context, initialTime: _startTime);
    if (t != null) {
      setState(() {
        _startTime = t;
      });
    }
  }

  void pickEndTime() async {
    TimeOfDay t =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) {
      setState(() {
        _endTime = t;
      });
    }
  }

  void pickLogDate() async {
    DateTime date = await showDatePicker(
        context: context,
        initialDate: _logDate,
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 5));

    if (date != null) {
      setState(() {
        _logDate = date;
      });
    }
  }
}
