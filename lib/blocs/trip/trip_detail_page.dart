import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:yvrkayakers/blocs/trip/index.dart';
import 'package:yvrkayakers/blocs/user/user_model.dart';
import 'package:yvrkayakers/common/common_functions.dart';
import 'package:yvrkayakers/widgets/widgets.dart';

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

  StreamController currentTripController =
      StreamController.broadcast(); //Add .broadcast here
  bool blnNeedRide = false;
  TextEditingController txtAvailableSpace = TextEditingController();
  bool blnParticipated = false;
  TextEditingController txtAddComment = TextEditingController();
  @override
  void initState() {
    super.initState();
    var tripReference = FirebaseFirestore.instance
        .collection('trips')
        .where("id", isEqualTo: widget._foundTrip.id);
    currentTripController.addStream(tripReference.snapshots());

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
      body: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              tripDetailWidget(),
              Column(
                children: [],
              )
            ],
          ),
          StreamBuilder(
              stream: this.currentTripController.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.data.docs.first.data()['participants'].length ==
                    0) {
                  return Row(
                    children: [
                      Container(
                          alignment: Alignment.center,
                          child: FaIcon(FontAwesomeIcons.userPlus,
                              size: 20, color: Color.fromARGB(15, 0, 0, 0))),
                      carpoolWidget(false)
                    ],
                  );
                }
                var allParticipants = snapshot.data.docs.first
                    .data()['participants']
                    .toList()
                    .map<TripParticipantModel>(
                        (e) => TripParticipantModel.fromJson(e))
                    .toList();
                var allComments = snapshot.data.docs.first.reference
                    .collection('/comments')
                    .get()
                    .then((event) {
                  return event.docs
                      .map<TripCommentModel>(
                          (e) => TripCommentModel.fromFire(e))
                      .toList();
                });

                // snapshot.data.docs.first
                //     .data()['comments']
                //     .toList()
                //     .map<TripCommentModel>(
                //         (e) => TripCommentModel.fromJson(e))
                //     .toList();
                return FutureBuilder(
                    future: FlutterSession().get("currentUserId"),
                    builder: (context, sessionSnapshot) {
                      blnParticipated = allParticipants.any(
                          (element) => element.userId == sessionSnapshot.data);

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          participantListWidget(allParticipants),
                          carpoolWidget(blnParticipated),
                          commentWidget(allComments)
                        ],
                      );
                    });
              }),
        ],
      )),
    );
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
    TripParticipantModel newParticipant = new TripParticipantModel(
        currentUserId,
        currentUser.displayName,
        blnNeedRide,
        (txtAvailableSpace.text == "") ? 0 : int.parse(txtAvailableSpace.text),
        userSkill,
        userSkillVerified,
        currentUser.photoUrl);
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

  Widget tripDetailWidget() {
    return Column(
      children: [
        Text(widget._foundTrip.tripDate.toString()),
        Text(widget._foundTrip.river.riverName,
            style: TextStyle(fontSize: 20.0)),
        Text(widget._foundTrip.river.sectionName),
        Text('Difficulty: ' + widget._foundTrip.river.difficulty.toString()),
      ],
    );
  }

  Widget commentWidget(Future<dynamic> allComments) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: this.txtAddComment,
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: "Add Comment..."),
              ),
            ),
            RaisedButton(
                child: Text('Add Comment'),
                onPressed: () {
                  addComment(context);
                })
          ],
        ),
        FutureBuilder(
          future: allComments,
          builder: (context, snapshot) {
            if (snapshot.hasData == false) return Text('');
            return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return SpeechBubble(
                    avatarUrl: snapshot.data[index].userPicUrl,
                    message: snapshot.data[index].message,
                    time: CommonFunctions.formatPostDateForDisplay(
                        snapshot.data[index].createdDate),
                    delivered: true,
                    isMe: false);
              },
            );
          },
        )
        // ignore: missing_required_param
      ],
    );
  }

  Widget participantListWidget(List<TripParticipantModel> allParticipants) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: allParticipants.length,
        itemBuilder: (context, index) {
          TripParticipantModel currentParticipant = allParticipants[index];
          var paddlerWeight = (currentParticipant.skillLevel <
                  widget._foundTrip.river.difficulty)
              ? "-1"
              : (currentParticipant.skillLevel >
                      widget._foundTrip.river.difficulty)
                  ? "+1"
                  : "";
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: 20.0,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: CachedNetworkImageProvider(
                      currentParticipant.userPhotoUrl),
                ),
                RichText(
                    text: TextSpan(
                  text: paddlerWeight,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          (paddlerWeight == "-1") ? Colors.red : Colors.green,
                      fontSize: 20),
                )),
                Text(currentParticipant.userDisplayName),
                Container(
                    alignment: Alignment.center,
                    height: 20.0,
                    width: 20.0,
                    decoration: new BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: new BorderRadius.circular(10.0)),
                    child: Text(
                      CommonFunctions.translateRiverDifficulty(
                          currentParticipant.skillLevel),
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    )),
                (currentParticipant.needRide == true)
                    ? FaIcon(FontAwesomeIcons.child,
                        size: 20, color: Colors.red)
                    : FaIcon(FontAwesomeIcons.car,
                        size: 20,
                        color: (currentParticipant.availableSpace > 0)
                            ? Colors.green
                            : Colors.blue),
                (currentParticipant.availableSpace > 0)
                    ? RichText(
                        text: TextSpan(
                        text:
                            '+' + currentParticipant.availableSpace.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 20),
                      ))
                    : Text(''),
              ]);
        });
  }

  void addComment(BuildContext context) async {
    var session = FlutterSession();
    var currentUser = UserModel.fromJson(await session.get("loggedInUser"));
    var currentUserId = (await session.get("currentUserId"));

    var newComment = new TripCommentModel(
        currentUserId,
        currentUser.displayName,
        currentUser.photoUrl,
        txtAddComment.text,
        DateTime.now());
    txtAddComment.text = "";
    BlocProvider.of<TripBloc>(context)
        .add(new AddingCommentTripEvent(widget._foundTrip.id, newComment));
  }
}
