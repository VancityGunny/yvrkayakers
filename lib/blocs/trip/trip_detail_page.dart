import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yvrkayakers/blocs/trip/index.dart';
import 'package:yvrkayakers/blocs/user/user_model.dart';
import 'package:yvrkayakers/common/common_functions.dart';
import 'package:yvrkayakers/widgets/widgets.dart';
import 'package:yvrkayakers/blocs/riverlog/index.dart';
import 'package:yvrkayakers/blocs/auth/index.dart';

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

  // not allow change 1 hour before the trip date
  bool get isLocked {
    return DateTime.now()
        .add(Duration(hours: -1))
        .isAfter(widget._foundTrip.tripDate);
  }

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
          StreamBuilder(
              stream: this.currentTripController.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
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

                blnParticipated = allParticipants.any((element) =>
                    element.userId == FirebaseAuth.instance.currentUser.uid);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        tripDetailWidget(),
                        Container(child: carpoolWidget(blnParticipated)),
                      ],
                    ),
                    Container(
                      child: participantListWidget(allParticipants),
                    ),
                    Container(child: commentWidget(allComments))
                  ],
                );
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
    var currentUser = BlocProvider.of<AuthBloc>(context).currentAuth.value;
    var userSkill = currentUser.userSkill;
    var userSkillVerified = currentUser.userSkillVerified;
    TripParticipantModel newParticipant = new TripParticipantModel(
        FirebaseAuth.instance.currentUser.uid,
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
            onPressed: isLocked
                ? null
                : () {
                    leaveThisTrip();
                  },
            child: Text("Leave"),
          )
        ],
      );
    } else {
      return Column(
        children: [
          Text('Ride?'),
          Container(
              child: Checkbox(
            onChanged: (value) {
              setState(() {
                this.blnNeedRide = value;
              });
            },
            value: blnNeedRide,
          )),
          Row(
            children: [
              Container(
                width: 60.0,
                child: TextField(
                  controller: this.txtAvailableSpace,
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: "Space?"),
                ),
              )
            ],
          ),
          RaisedButton(
            onPressed: isLocked
                ? null
                : () {
                    joinThisTrip();
                  },
            child: Text("Join"),
          ),
        ],
      );
    }
  }

  Future<void> leaveThisTrip() async {
    BlocProvider.of<TripBloc>(context).add(new LeaveTripEvent(
        widget._foundTrip.id, FirebaseAuth.instance.currentUser.uid));
  }

  Widget tripDetailWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            RiverGradeBadge(widget._foundTrip.river),
            Column(
              children: [
                Text(widget._foundTrip.river.riverName,
                    style: Theme.of(context).textTheme.headline2),
                Text(widget._foundTrip.river.sectionName,
                    style: Theme.of(context).textTheme.subtitle1),
              ],
            )
          ],
        ),
        Text(widget._foundTrip.tripDate.toString()),
      ],
    );
  }

  Widget commentWidget(Future<dynamic> allComments) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextField(
                controller: this.txtAddComment,
                keyboardType: TextInputType.multiline,
                minLines: 2, //Normal textInputField will be displayed
                maxLines: 2, // when user presses enter it will adapt to it
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: "Add Comment..."),
              ),
            )),
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
            List<TripCommentModel> sortedList = snapshot.data;
            sortedList.sort((a, b) => a.createdDate.compareTo(b.createdDate));
            return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: sortedList.length,
              itemBuilder: (context, index) {
                return SpeechBubble(
                  avatarUrl: sortedList[index].userPicUrl,
                  message: sortedList[index].message,
                  time: CommonFunctions.formatPostDateForDisplay(
                      sortedList[index].createdDate),
                  delivered: true,
                  isMe: true,
                  userDisplayName: sortedList[index].userDisplayName,
                  onTouched: () {
                    goToUserRiverlogPage(sortedList[index].userId);
                  },
                );
              },
            );
          },
        ),
        Text('')
        // ignore: missing_required_param
      ],
    );
  }

  Widget participantListWidget(List<TripParticipantModel> allParticipants) {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
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
                GestureDetector(
                  onTap: () {
                    goToUserRiverlogPage(currentParticipant.userId);
                  },
                  child: CircleAvatar(
                    radius: 20.0,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: CachedNetworkImageProvider(
                        currentParticipant.userPhotoUrl),
                  ),
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

    var newComment = new TripCommentModel(
        FirebaseAuth.instance.currentUser.uid,
        currentUser.displayName,
        currentUser.photoUrl,
        txtAddComment.text,
        DateTime.now());
    txtAddComment.text = "";
    BlocProvider.of<TripBloc>(context)
        .add(new AddingCommentTripEvent(widget._foundTrip.id, newComment));
  }

  void goToUserRiverlogPage(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) {
        return RiverlogPage(userId);
      }),
    );
  }
}
