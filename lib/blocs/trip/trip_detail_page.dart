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
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';

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
    return CommonFunctions.getTripLockDateTime()
        .isAfter(widget._foundTrip.tripDate);
  }

  StreamController currentTripController =
      StreamController.broadcast(); //Add .broadcast here
  bool blnNeedRide = false;
  double availableSpace = 0.0;
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
                if (snapshot == null ||
                    snapshot.hasError ||
                    !snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.data.docs?.isEmpty == false) {
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
                      Card(
                          elevation: 5.0,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              tripDetailWidget(),
                              Flexible(child: carpoolWidget(blnParticipated)),
                            ],
                          )),
                      Container(
                        child: participantListWidget(allParticipants),
                      ),
                      Container(child: commentWidget(allComments))
                    ],
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
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
        currentUser.userName,
        blnNeedRide,
        availableSpace.toInt(),
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
          IconButton(
            onPressed: isLocked
                ? null
                : () {
                    showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: Text('Leave this trip?'),
                            actions: <Widget>[
                              FlatButton(
                                onPressed: () {
                                  leaveThisTrip();
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  Navigator.of(context)
                                      .pop(); // go back to main trip screen
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
                        },
                        barrierDismissible: false);
                  },
            icon: FaIcon(FontAwesomeIcons.signOutAlt),
            color: Colors.red,
            tooltip: "Leave Trip",
          )
        ],
      );
    } else {
      return Column(
        children: [
          IconButton(
            onPressed: isLocked
                ? null
                : () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(builder: (context, setState) {
                            return AlertDialog(
                              title: Text('Join this trip?'),
                              content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        IconButton(
                                            iconSize: 60.0,
                                            color: (blnNeedRide == true)
                                                ? Colors.red
                                                : Colors.grey,
                                            icon: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 4, right: 4, top: 0),
                                                child: FaIcon(
                                                    FontAwesomeIcons.child)),
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
                                            color: (blnNeedRide == false)
                                                ? Colors.green
                                                : Colors.grey,
                                            icon: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 4, right: 4, top: 0),
                                                child: FaIcon(
                                                    FontAwesomeIcons.car)),
                                            onPressed: () {
                                              setState(() {
                                                if (blnNeedRide == false) {
                                                  availableSpace = 0;
                                                }
                                                blnNeedRide = !blnNeedRide;
                                              });
                                            }),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                          color: (availableSpace > 0)
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                        FaIcon(
                                          FontAwesomeIcons.chair,
                                          size: 30.0,
                                          color: (availableSpace > 1)
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                        FaIcon(
                                          FontAwesomeIcons.chair,
                                          size: 30.0,
                                          color: (availableSpace > 2)
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Slider(
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
                                        ),
                                      ],
                                    )
                                  ]),
                              actions: <Widget>[
                                FlatButton(
                                  onPressed: () {
                                    joinThisTrip();
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
            icon: FaIcon(FontAwesomeIcons.signInAlt),
            color: Colors.green,
            tooltip: "Join Trip",
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            RiverGradeBadge(widget._foundTrip.river),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget._foundTrip.river.riverName,
                    style: Theme.of(context).textTheme.headline2),
                Text(widget._foundTrip.river.sectionName,
                    style: Theme.of(context).textTheme.subtitle1),
              ],
            )
          ],
        ),
        Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FaIcon(FontAwesomeIcons.calendar, size: 15.0),
                Text(DateFormat.yMMMd()
                    .add_jm()
                    .format(widget._foundTrip.tripDate)),
              ],
            )),
        Text(widget._foundTrip.note),
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
            Padding(
                padding: EdgeInsets.all(5.0),
                child: RaisedButton(
                    child: FaIcon(
                      FontAwesomeIcons.commentMedical,
                    ),
                    onPressed: () {
                      addComment(context);
                    }))
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
                  : "0";
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: GestureDetector(
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
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: RichText(
                      text: TextSpan(
                    text: paddlerWeight,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            (paddlerWeight == "-1") ? Colors.red : Colors.green,
                        fontSize: 20),
                  )),
                ),
                Flexible(
                  flex: 3,
                  fit: FlexFit.tight,
                  child: Text("@" + currentParticipant.userName),
                ),
                Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: UserSkillMedal(currentParticipant.skillLevel)),
                Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: (currentParticipant.needRide == true)
                      ? FaIcon(FontAwesomeIcons.child,
                          size: 20, color: Colors.red)
                      : FaIcon(FontAwesomeIcons.car,
                          size: 20,
                          color: (currentParticipant.availableSpace > 0)
                              ? Colors.green
                              : Colors.blue),
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: (currentParticipant.availableSpace > 0)
                      ? Row(
                          children: [
                            RichText(
                                text: TextSpan(
                              text: '+' +
                                  currentParticipant.availableSpace.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  fontSize: 20),
                            )),
                            FaIcon(FontAwesomeIcons.chair,
                                size: 20, color: Colors.green),
                          ],
                        )
                      : Text(''),
                )
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
