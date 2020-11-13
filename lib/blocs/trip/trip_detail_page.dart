import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yvrkayakers/blocs/trip/index.dart';
import 'package:yvrkayakers/blocs/user/user_model.dart';
import 'package:yvrkayakers/common/common_functions.dart';

class TripDetailPage extends StatefulWidget {
  TripModel _foundTrip;
  TripDetailPage(this._foundTrip);
  @override
  TripDetailPageState createState() {
    return TripDetailPageState();
  }
}

class TripDetailPageState extends State<TripDetailPage> {
  TripDetailPageState();

  StreamController tripController =
      StreamController.broadcast(); //Add .broadcast here
  bool blnNeedRide = false;
  TextEditingController txtAvailableSpace = TextEditingController();
  bool blnParticipated = false;

  @override
  void initState() {
    super.initState();
    var tripReference = FirebaseFirestore.instance
        .collection('trips')
        .where("id", isEqualTo: widget._foundTrip.id);
    tripController.addStream(tripReference.snapshots());

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
          title: Text(widget._foundTrip.river.riverName),
        ),
        body: Column(
          children: [
            Text(widget._foundTrip.tripDate.toString()),
            Text(widget._foundTrip.river.riverName,
                style: TextStyle(fontSize: 20.0)),
            Text(widget._foundTrip.river.sectionName),
            Text(
                'Difficulty: ' + widget._foundTrip.river.difficulty.toString()),
            StreamBuilder(
                stream: this.tripController.stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.data.docs.first.data()['participants'].length ==
                      0) {
                    return Column(
                      children: [
                        Container(
                            alignment: Alignment.center,
                            child: FaIcon(FontAwesomeIcons.userPlus,
                                size: 20, color: Color.fromARGB(15, 0, 0, 0))),
                        carpoolWidget(false)
                      ],
                    );
                  }

                  return FutureBuilder(
                      future: FlutterSession().get("currentUserId"),
                      builder: (context, sessionSnapshot) {
                        blnParticipated = snapshot.data.docs.first
                            .data()['participants']
                            .any((element) =>
                                element['userId'] == sessionSnapshot.data);
                        return Expanded(
                            child: Column(
                          children: [
                            ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: snapshot.data.docs.first
                                    .data()['participants']
                                    .length,
                                itemBuilder: (context, index) {
                                  TripParticipant currentParticipant =
                                      TripParticipant.fromJson(snapshot
                                          .data.docs.first
                                          .data()['participants'][index]);
                                  var paddlerWeight = (currentParticipant
                                              .skillLevel <
                                          widget._foundTrip.river.difficulty)
                                      ? "-1"
                                      : (currentParticipant.skillLevel >
                                              widget
                                                  ._foundTrip.river.difficulty)
                                          ? "+1"
                                          : "";
                                  return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        RichText(
                                            text: TextSpan(
                                          text: paddlerWeight,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: (paddlerWeight == "-1")
                                                  ? Colors.red
                                                  : Colors.green,
                                              fontSize: 20),
                                        )),
                                        Text(
                                            currentParticipant.userDisplayName),
                                        Container(
                                            alignment: Alignment.center,
                                            height: 20.0,
                                            width: 20.0,
                                            decoration: new BoxDecoration(
                                                color: Colors.deepOrange,
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        10.0)),
                                            child: Text(
                                              CommonFunctions
                                                  .translateRiverDifficulty(
                                                      currentParticipant
                                                          .skillLevel),
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white),
                                            )),
                                        (currentParticipant.needRide == true)
                                            ? FaIcon(FontAwesomeIcons.child,
                                                size: 20, color: Colors.red)
                                            : FaIcon(FontAwesomeIcons.car,
                                                size: 20,
                                                color: (currentParticipant
                                                            .availableSpace >
                                                        0)
                                                    ? Colors.green
                                                    : Colors.blue),
                                        (currentParticipant.availableSpace > 0)
                                            ? RichText(
                                                text: TextSpan(
                                                text: currentParticipant
                                                        .availableSpace
                                                        .toString() +
                                                    ' space',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green,
                                                    fontSize: 20),
                                              ))
                                            : Text(''),
                                      ]);
                                }),
                            carpoolWidget(blnParticipated),
                          ],
                        ));
                      });
                }),
          ],
        ));
  }

  void _load([bool isError = false]) {
    //widget._riverbetaBloc.add(LoadTripEvent(isError));
  }

  Future<void> joinThisTrip() async {
    var session = FlutterSession();
    var currentUser = UserModel.fromJson(await session.get("loggedInUser"));
    var currentUserId = (await session.get("currentUserId"));
    var userSkill = currentUser.userSkill;
    var userSkillVerified = currentUser.userSkillVerified;
    TripParticipant newParticipant = new TripParticipant(
        currentUserId,
        currentUser.displayName,
        blnNeedRide,
        (txtAvailableSpace.text == "") ? 0 : int.parse(txtAvailableSpace.text),
        userSkill,
        userSkillVerified);
    BlocProvider.of<TripBloc>(context)
        .add(new JoinTripEvent(widget._foundTrip.id, newParticipant));
  }

  Widget carpoolWidget(bool isParticipated) {
    if (isParticipated) {
      return Column(
        children: [
          RaisedButton(
            onPressed: () {
              leaveThisTrip();
            },
            child: Text("Leave this trip"),
          )
        ],
      );
    } else {
      return Column(
        children: [
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
          RaisedButton(
            onPressed: () {
              joinThisTrip();
            },
            child: Text("Join this trip"),
          ),
        ],
      );
    }
  }

  Future<void> leaveThisTrip() async {
    var session = FlutterSession();
    var currentUserId = (await session.get("currentUserId"));
    BlocProvider.of<TripBloc>(context)
        .add(new LeaveTripEvent(widget._foundTrip.id, currentUserId));
  }
}
