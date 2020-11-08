import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';
import 'package:yvrkayakers/blocs/trip/index.dart';
import 'package:yvrkayakers/blocs/user/user_model.dart';

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
  TextEditingController txtTripDate = TextEditingController();
  TextEditingController txtAvailableSpace = TextEditingController();
  TextEditingController txtNote = TextEditingController();

  bool blnNeedRide = false;
  DateTime _tripDate;
  TimeOfDay _tripTime;
  TripAddPageState();
  @override
  void initState() {
    super.initState();
    _tripTime = TimeOfDay.now();
    _tripDate = DateTime.now();
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
          Text(widget._selectedRiver.riverName),
          ListTile(
              title: Text(
                  "Trip Date:${_tripDate.year}/${_tripDate.month}/${_tripDate.day}"),
              onTap: pickTripDate),
          ListTile(
              title: Text("Start: ${_tripTime.hour}:${_tripTime.minute}"),
              onTap: pickTripTime),
          Row(
            children: [
              Expanded(
                  child: Checkbox(
                onChanged: (value) {
                  setState(() {
                    this.blnNeedRide = value;
                  });
                },
                value: blnNeedRide,
              )),
              Text('Need a Ride?')
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: this.txtAvailableSpace,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Available Space in Car?"),
                ),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: this.txtNote,
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: "Note?"),
                ),
              )
            ],
          ),
          RaisedButton(
              child: Text('Add New Trip'),
              onPressed: () {
                addNewTrip(context); // go up one level
              })
        ],
      ),
    );
  }

  void addNewTrip(BuildContext context) async {
    var session = FlutterSession();
    var currentUser = UserModel.fromJson(await session.get("loggedInUser"));
    var currentUserId = (await session.get("currentUserId"));
    var uuid = new Uuid();
    var tripId = uuid.v1();
    //(widget._selectedRiver as RiverbetaShortModel).toJson()
    var newTripParticipants = List<TripParticipant>();
    newTripParticipants.add(TripParticipant(
        currentUserId,
        currentUser.displayName,
        blnNeedRide,
        (txtAvailableSpace.text == "")
            ? 0
            : int.parse(txtAvailableSpace.text)));
    TripModel newTrip = TripModel(tripId, widget._selectedRiver, this._tripDate,
        txtNote.text, newTripParticipants, currentUserId);
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
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 5));

    if (date != null) {
      setState(() {
        _tripDate = date;
      });
    }
  }
}
