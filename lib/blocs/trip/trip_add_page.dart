import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:uuid/uuid.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';
import 'package:yvrkayakers/blocs/trip/index.dart';
import 'package:yvrkayakers/blocs/user/user_model.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TripAddPage extends StatefulWidget {
  final RiverbetaModel _selectedRiver;

  @override
  TripAddPage(this._selectedRiver);

  @override
  TripAddPageState createState() {
    return TripAddPageState();
  }
}

class TripAddPageState extends State<TripAddPage> {
  TextEditingController txtNote = TextEditingController();
  double availableSpace = 0;
  bool blnNeedRide = false;
  DateTime _tripDate;
  TimeOfDay _tripTime;
  TripAddPageState();
  @override
  void initState() {
    super.initState();
    _tripTime = TimeOfDay(hour: 10, minute: 0);
    _tripDate = DateTime.now().add(Duration(days: 1));
    _load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _load([bool isError = false]) {
    //widget._riverbetaBloc.add(LoadRiverbetaEvent(isError));
    //Load RiverBeta list to dropdownbutton
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Propose Trip"),
        ),
        body: newTripForm());
  }

  Widget newTripForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            widget._selectedRiver.riverName,
            style: Theme.of(context).textTheme.headline1,
          ),
          ListTile(
              contentPadding: EdgeInsets.all(2.0),
              tileColor: Colors.grey.shade300,
              enabled: true,
              dense: true,
              title: Text(
                  "Trip Date:${_tripDate.year}/${_tripDate.month}/${_tripDate.day}",
                  style: Theme.of(context).textTheme.headline3),
              onTap: pickTripDate),
          SizedBox(height: 2),
          ListTile(
              contentPadding: EdgeInsets.all(2.0),
              tileColor: Colors.grey.shade300,
              enabled: true,
              dense: true,
              title: Text(
                  "Start: ${MaterialLocalizations.of(context).formatTimeOfDay(_tripTime)}",
                  style: Theme.of(context).textTheme.headline3),
              onTap: pickTripTime),
          Row(
            children: [
              IconButton(
                  iconSize: 60.0,
                  color: (blnNeedRide == true) ? Colors.red : Colors.grey,
                  icon: Padding(
                      padding: EdgeInsets.only(left: 4, right: 4, top: 0),
                      child: FaIcon(FontAwesomeIcons.child)),
                  onPressed: () {
                    setState(() {
                      if (blnNeedRide == false) {
                        availableSpace = 0;
                      }
                      blnNeedRide = !blnNeedRide;
                    });
                  }),
              IconButton(
                  iconSize: 60.0,
                  color: (blnNeedRide == false) ? Colors.green : Colors.grey,
                  icon: Padding(
                      padding: EdgeInsets.only(left: 4, right: 4, top: 0),
                      child: FaIcon(FontAwesomeIcons.car)),
                  onPressed: () {
                    setState(() {
                      if (blnNeedRide == false) {
                        availableSpace = 0;
                      }
                      blnNeedRide = !blnNeedRide;
                    });
                  }),
              Column(
                children: [
                  Row(
                    children: [
                      Text(
                        (availableSpace > 0)
                            ? '+${availableSpace.toInt().toString()}'
                            : '${availableSpace.toInt().toString()}',
                        style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            color: (availableSpace > 0)
                                ? Colors.green
                                : Colors.grey),
                      ),
                      SizedBox(width: 10.0),
                      FaIcon(
                        FontAwesomeIcons.chair,
                        size: 30.0,
                        color:
                            (availableSpace > 0) ? Colors.green : Colors.grey,
                      ),
                      FaIcon(
                        FontAwesomeIcons.chair,
                        size: 30.0,
                        color:
                            (availableSpace > 1) ? Colors.green : Colors.grey,
                      ),
                      FaIcon(
                        FontAwesomeIcons.chair,
                        size: 30.0,
                        color:
                            (availableSpace > 2) ? Colors.green : Colors.grey,
                      ),
                    ],
                  ),
                  Container(
                      width: 250.0,
                      child: Center(
                          child: Slider(
                        min: 0,
                        max: 3,
                        divisions: 3,
                        value: availableSpace,
                        onChanged: (blnNeedRide == true)
                            ? null
                            : (double value) {
                                setState(() {
                                  availableSpace = value;
                                });
                              },
                      ))),
                ],
              )
            ],
          ),
          ListTile(
            tileColor: Colors.grey.shade300,
            title: TextField(
              controller: this.txtNote,
              keyboardType: TextInputType.multiline,
              minLines: 3, //Normal textInputField will be displayed
              maxLines: 3, // when user presses enter it will adapt to it
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: "Note?..."),
            ),
          ),
          SizedBox(height: 5),
          ButtonTheme(
              minWidth: 200.0,
              height: 70.0,
              child: RaisedButton(
                  child: Text(
                    'Add New Trip',
                    style: TextStyle(fontSize: 30.0),
                  ),
                  onPressed: () {
                    addNewTrip(context); // go up one level
                  }))
        ],
      ),
    );
  }

  void addNewTrip(BuildContext context) async {
    var session = FlutterSession();
    var currentUser = UserModel.fromJson(await session.get("loggedInUser"));
    var currentUserId = FirebaseAuth.instance.currentUser.uid;
    var uuid = new Uuid();
    var tripId = uuid.v1();
    var userSkill = currentUser.userSkill;
    var userSkillVerified = currentUser.userSkillVerified;
    //(widget._selectedRiver as RiverbetaShortModel).toJson()
    var newTripParticipants = List<TripParticipantModel>();
    newTripParticipants.add(
      TripParticipantModel(
          currentUserId,
          currentUser.userName,
          blnNeedRide,
          (availableSpace == null) ? 0 : availableSpace.toInt(),
          userSkill,
          userSkillVerified,
          currentUser.photoUrl),
    );
    DateTime tmpDateTime = DateTime(_tripDate.year, _tripDate.month,
        _tripDate.day, _tripTime.hour, _tripTime.minute);
    TripModel newTrip = TripModel(
        tripId,
        widget._selectedRiver.getRiverbetaShort(),
        tmpDateTime,
        txtNote.text,
        newTripParticipants,
        currentUserId,
        0);
    BlocProvider.of<TripBloc>(context).add(AddingTripEvent(newTrip));
    Navigator.of(context).pop();
  }

  void pickTripTime() async {
    TimeOfDay t =
        await showTimePicker(context: context, initialTime: _tripTime);
    if (t != null) {
      setState(() {
        _tripTime = t;
      });
    }
  }

  void pickTripDate() async {
    DateTime date = await showDatePicker(
        context: context,
        initialDate: _tripDate,
        firstDate: DateTime.now().add(Duration(days: 1)),
        lastDate: DateTime(DateTime.now().year + 5));

    if (date != null) {
      setState(() {
        _tripDate = date;
      });
    }
  }
}
