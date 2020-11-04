import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';
import 'package:yvrkayakers/blocs/riverlog/index.dart';

class RiverlogAddPage extends StatefulWidget {
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
  RiverbetaModel _selectedRiver = null;
  RiverlogAddPageState();
  @override
  void initState() {
    super.initState();
    _startTime = TimeOfDay.now();
    _endTime = TimeOfDay.now();
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
          Text("Add New River Log"),
          Row(
            children: [
              Expanded(
                  child: TextField(
                controller: this.txtRiverName,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "<<River Name>>",
                    labelText: "River Name"),
              ))
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
                return DropdownButton(
                  hint: Text("Select River"),
                  value: _selectedRiver,
                  items:
                      snapshot.data.map<DropdownMenuItem<RiverbetaModel>>((r) {
                    return DropdownMenuItem<RiverbetaModel>(
                        value: r, child: Text(r.riverName));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRiver = value;
                    });
                  },
                );
              }),
          Row(
            children: [
              Expanded(
                  child: TextField(
                controller: this.txtRiverLevel,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "<<Water Level>>",
                    labelText: "Water Level"),
              ))
            ],
          ),
          ListTile(
              title: Text(
                  "Log Date:${_logDate.year}/${_logDate.month}/${_logDate.day}"),
              onTap: pickLogDate),
          ListTile(
              title: Text("Start: ${_startTime.hour}:${_startTime.minute}"),
              onTap: pickStartTime),
          ListTile(
              title: Text("End: ${_endTime.hour}:${_endTime.minute}"),
              onTap: pickEndTime),
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
              Text('Swam?')
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
              Text('Rescue?')
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
    var session = FlutterSession();
    var currentUserId = (await session.get("currentUserId")).toString();
    var uuid = new Uuid();
    var logId = uuid.v1();
    RiverlogModel newRiverlog = RiverlogModel(
        logId,
        _selectedRiver.id,
        null,
        currentUserId,
        blnDidSwim,
        blnDidRescue,
        null,
        null,
        null,
        null,
        _selectedRiver.riverName,
        double.parse(txtRiverLevel.text), //waterlevel
        BlocProvider.of<RiverbetaBloc>(context)
            .allRiverbetas
            .value
            .where((x) => x.id == _selectedRiver.id)
            .first
            .difficulty, //riverdifficulty
        _logDate, //logdate
        null, //friends
        0, //totalround
        0, //riverround
        _selectedRiver.sectionName);
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
    TimeOfDay t = await showTimePicker(context: context, initialTime: _endTime);
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
