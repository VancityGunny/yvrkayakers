import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';
import 'package:yvrkayakers/blocs/riverlog/index.dart';
import 'package:yvrkayakers/widgets/widgets.dart';
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
  TextEditingController txtLogDate = TextEditingController();
  TextEditingController txtLogTimeIn = TextEditingController();
  TextEditingController txtLogTimeOut = TextEditingController();
  TextEditingController txtNote = TextEditingController();
  bool blnDidSwim = false;
  bool blnDidRescue = false;
  DateTime _logDate;
  TimeOfDay _startTime;
  TimeOfDay _endTime;
  double _selectedWaterLevel;
  int _gaugeDivision = 0;
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
    // //Load RiverBeta list to dropdownbutton
    // location.getLocation().then((value) {
    //   var myLocation = GeoFirePoint(value.latitude, value.longitude);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Log ${widget._selectedRiver.riverName} Run"),
        ),
        body: newRiverLogForm());
  }

  Widget newRiverLogForm() {
    if (widget._selectedRiver.maxFlow == null) {
      _gaugeDivision = 1;
    } else {
      // all this just to avoid Floating-point error
      int tmpMax = (widget._selectedRiver.maxFlow * 100).toInt();
      int tmpMin = (widget._selectedRiver.minFlow * 100).toInt();
      int tmpIncrement = (widget._selectedRiver.levelIncrement * 100).toInt();
      _gaugeDivision = (tmpMax - tmpMin) ~/ tmpIncrement;
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.all(2.0),
                      tileColor: Colors.grey.shade300,
                      enabled: true,
                      dense: true,
                      title: Text(
                          "Log Date:${_logDate.year}/${_logDate.month}/${_logDate.day}",
                          style: Theme.of(context).textTheme.headline3),
                      onTap: pickLogDate,
                    ),
                    SizedBox(height: 2),
                    ListTile(
                        contentPadding: EdgeInsets.all(2.0),
                        tileColor: Colors.grey.shade300,
                        enabled: true,
                        dense: true,
                        title: Text(
                            "Start: ${MaterialLocalizations.of(context).formatTimeOfDay(_startTime)}",
                            style: Theme.of(context).textTheme.headline3),
                        onTap: pickStartTime),
                    SizedBox(height: 2),
                    ListTile(
                        contentPadding: EdgeInsets.all(2.0),
                        tileColor: Colors.grey.shade300,
                        enabled: true,
                        dense: true,
                        title: Text(
                            (_endTime == null)
                                ? "End: <Select Time>"
                                : "End: ${MaterialLocalizations.of(context).formatTimeOfDay(_endTime)}",
                            style: Theme.of(context).textTheme.headline3),
                        onTap: pickEndTime),
                    SizedBox(height: 2),
                    ListTile(
                      contentPadding: EdgeInsets.all(2.0),
                      tileColor: Colors.grey.shade300,
                      title: TextField(
                        controller: this.txtNote,
                        keyboardType: TextInputType.multiline,
                        minLines: 3, //Normal textInputField will be displayed
                        maxLines:
                            3, // when user presses enter it will adapt to it
                        decoration: InputDecoration(
                            border: InputBorder.none, hintText: "Note?..."),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                iconSize: 50.0,
                                color: (blnDidSwim == true)
                                    ? Colors.red
                                    : Colors.grey,
                                icon: FaIcon(FontAwesomeIcons.swimmer),
                                onPressed: () {
                                  setState(() {
                                    blnDidSwim = !blnDidSwim;
                                  });
                                }),
                            Text(
                              "I Swam",
                              style: Theme.of(context).textTheme.button,
                            )
                          ],
                        ),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                  iconSize: 50.0,
                                  color: (blnDidRescue == true)
                                      ? Colors.green
                                      : Colors.grey,
                                  icon: FaIcon(FontAwesomeIcons.lifeRing),
                                  onPressed: () {
                                    setState(() {
                                      blnDidRescue = !blnDidRescue;
                                    });
                                  }),
                              Text(
                                "I Rescued",
                                style: Theme.of(context).textTheme.button,
                              )
                            ]),
                      ],
                    ),
                    ButtonTheme(
                        minWidth: 200.0,
                        height: 70.0,
                        child: RaisedButton(
                            child: Text(
                              'Add New Log',
                              style: TextStyle(fontSize: 30.0),
                            ),
                            onPressed: () {
                              addNewRiverlog(context); // go up one level
                            }))
                  ],
                ),
              ),
              Flexible(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 280.0,
                        child: Center(
                            child: RotatedBox(
                                quarterTurns: -1,
                                child: Slider(
                                  min: (widget._selectedRiver.maxFlow == null)
                                      ? 1
                                      : widget._selectedRiver.minFlow,
                                  max: (widget._selectedRiver.maxFlow == null)
                                      ? 1
                                      : widget._selectedRiver.maxFlow,
                                  divisions: _gaugeDivision,
                                  onChanged: (widget._selectedRiver.maxFlow ==
                                          null)
                                      ? null
                                      : (double value) {
                                          setState(() {
                                            _selectedWaterLevel = double.parse(
                                                (value).toStringAsFixed(2));
                                          });
                                        },
                                  value: (widget._selectedRiver.maxFlow == null)
                                      ? 1
                                      : (_selectedWaterLevel == null)
                                          ? widget._selectedRiver.minFlow
                                          : _selectedWaterLevel,
                                ))),
                      ),
                      Stack(
                        alignment: AlignmentDirectional.topCenter,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.water,
                            size: 50.0,
                            color: (widget._selectedRiver.maxFlow == null)
                                ? Colors.grey.shade300
                                : Colors.blue.shade200,
                          ),
                          Column(
                            children: [
                              Text(
                                  (_selectedWaterLevel == null)
                                      ? "N/A"
                                      : _selectedWaterLevel.toString(),
                                  style: TextStyle(
                                      color: (widget._selectedRiver.maxFlow ==
                                              null)
                                          ? Colors.grey
                                          : Colors.blue.shade700,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                widget._selectedRiver.gaugeUnit,
                                style: TextStyle(
                                    color:
                                        (widget._selectedRiver.maxFlow == null)
                                            ? Colors.grey
                                            : Colors.blue.shade700,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  ))
            ],
          ),
        ],
      ),
    );
  }

  void addNewRiverlog(BuildContext context) async {
    var currentUserId = FirebaseAuth.instance.currentUser.uid;
    var uuid = new Uuid();
    var logId = uuid.v1();
    DateTime tmpDateTime = DateTime(_logDate.year, _logDate.month, _logDate.day,
        _startTime.hour, _startTime.minute);
    DateTime tmpDateTimeEnd = (_endTime == null)
        ? null
        : DateTime(_logDate.year, _logDate.month, _logDate.day, _endTime.hour,
            _endTime.minute);
    RiverlogModel newRiverlog = RiverlogModel(
        logId,
        null,
        currentUserId,
        blnDidSwim,
        blnDidRescue,
        null, //swimmerRescued
        null, //rescuedBy
        txtNote.text, //note
        null, //enjoyment
        _selectedWaterLevel, //waterlevel
        tmpDateTime, //logdate
        null, //friends
        0, //totalround
        0, //riverround
        widget._selectedRiver.getRiverbetaShort(),
        tmpDateTimeEnd);
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
        firstDate: DateTime(DateTime.now().year - 12),
        lastDate: DateTime.now());

    if (date != null) {
      setState(() {
        _logDate = date;
      });
    }
  }
}
