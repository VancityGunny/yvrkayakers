import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_list_view/group_list_view.dart';
import 'package:intl/intl.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:yvrkayakers/blocs/riverlog/index.dart';
import 'package:yvrkayakers/blocs/user/user_model.dart';
import 'package:yvrkayakers/common/common_functions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:yvrkayakers/widgets/widgets.dart';

class RiverlogScreen extends StatefulWidget {
  @override
  RiverlogScreenState createState() {
    return RiverlogScreenState();
  }
}

class RiverlogScreenState extends State<RiverlogScreen> {
  RiverlogScreenState();

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
    return SingleChildScrollView(
        child: StreamBuilder(
            stream: BlocProvider.of<RiverlogBloc>(context).allRiverLogs.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.data.length == 0) {
                return Container(
                    alignment: Alignment.center,
                    child: FaIcon(FontAwesomeIcons.userPlus,
                        size: 150, color: Color.fromARGB(15, 0, 0, 0)));
              }

              List<RiverlogShortModel> tempData = snapshot.data;
              tempData.sort((a, b) => b.logDate.compareTo(a.logDate));
              var newGroupedData = groupBy(
                  tempData,
                  (RiverlogShortModel obj) =>
                      DateFormat.yMMM().format(obj.logDate));
              return Column(children: [
                UserExperienceCard(tempData),
                RiverlogList(newGroupedData: newGroupedData)
              ]);
            }));
  }

  void _load([bool isError = false]) {
    var currentUserId = FirebaseAuth.instance.currentUser.uid;
    BlocProvider.of<RiverlogBloc>(context)
        .add(LoadUserRiverlogEvent(currentUserId));
  }
}

class UserExperienceCard extends StatelessWidget {
  List<RiverlogShortModel> _riverlogs;
  UserExperienceCard(this._riverlogs);
  @override
  Widget build(BuildContext context) {
    var session = FlutterSession();

    // TODO: implement build
    return FutureBuilder(
        future: session.get("loggedInUser"),
        builder: (context, snapshot) {
          if (snapshot.data == null) return Text('');
          var currentUser = UserModel.fromJson(snapshot.data);
          var groupExperience = groupBy(currentUser.experience,
                  (UserExperienceModel obj) => obj.riverGrade.roundToDouble())
              .map((key, value) => MapEntry<double, int>(
                  key, value.fold(0, (a, b) => a + b.runCount)));

          return Column(children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 50.0,
                  backgroundColor: Colors.grey[200],
                  backgroundImage:
                      CachedNetworkImageProvider(currentUser.photoUrl),
                ),
                Column(
                  children: [
                    Text(currentUser.displayName,
                        style: Theme.of(context).textTheme.headline1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("@" + currentUser.userName,
                            style: Theme.of(context).textTheme.headline4),
                        Text('   '),
                        Text(
                            "#" + CommonFunctions.getHashtag(user: currentUser),
                            style: Theme.of(context).textTheme.headline4),
                      ],
                    ),
                    Text(
                      "Favorite: " +
                          ((currentUser.userStat != null)
                              ? currentUser.userStat.favoriteRiver.riverName
                              : ""),
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    Text(
                        "Last Paddle: " +
                            ((currentUser.userStat != null)
                                ? DateFormat.yMMMd()
                                    .format(currentUser.userStat.lastWetness)
                                : ""),
                        style: Theme.of(context).textTheme.subtitle1),
                    LimitedBox(
                        maxHeight: 20.0,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: groupExperience.length,
                          itemBuilder: (context, index) {
                            var gradeLabel =
                                CommonFunctions.translateRiverDifficulty(
                                    groupExperience.keys.elementAt(index));
                            return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  RiverGradeIcon(
                                      groupExperience.keys.elementAt(index)),
                                  Text(" " +
                                      groupExperience.values
                                          .elementAt(index)
                                          .toString())
                                ]);
                          },
                        ))
                  ],
                )
              ],
            ),
          ]);
        });
  }
}

class RiverlogList extends StatelessWidget {
  const RiverlogList({
    Key key,
    @required this.newGroupedData,
  }) : super(key: key);

  final Map<String, List<RiverlogShortModel>> newGroupedData;

  @override
  Widget build(BuildContext context) {
    return GroupListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        sectionsCount: newGroupedData.length,
        countOfItemInSection: (int section) {
          return newGroupedData[newGroupedData.keys.toList()[section]].length;
        },
        groupHeaderBuilder: (BuildContext context, int section) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: Text(
              newGroupedData.keys.toList()[section].toString(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          );
        },
        separatorBuilder: (context, index) => SizedBox(height: 10),
        sectionSeparatorBuilder: (context, section) => SizedBox(height: 10),
        itemBuilder: (BuildContext context, IndexPath index) {
          var curRiver =
              newGroupedData[newGroupedData.keys.toList()[index.section]]
                  [index.index];
          return Card(
            elevation: 5,
            child: Padding(
              padding: EdgeInsets.all(7),
              child: Stack(children: <Widget>[
                Align(
                  alignment: Alignment.centerRight,
                  child: Stack(
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.only(left: 5, top: 5),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.date_range,
                                    size: 18.0,
                                    color: Theme.of(context).accentColor,
                                  ),
                                  Text(
                                      " ${DateFormat.yMMMd().format(curRiver.logDate)}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2),
                                  // Spacer(),
                                  // Container(
                                  //   child: Text(
                                  //       CommonFunctions.formatOrdinalNumber(
                                  //               curRiver.riverRound) +
                                  //           ' runs'),
                                  // ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  RiverGradeMedal(curRiver.river),
                                  riverNameSymbol(curRiver, context),
                                  Spacer(),
                                  waterLevelGauge(curRiver, context)
                                ],
                              )
                            ],
                          ))
                    ],
                  ),
                )
              ]),
            ),
          );
        });
  }

  Widget riverNameSymbol(RiverlogShortModel curRiverlog, BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: curRiverlog.river.riverName,
          style: Theme.of(context).textTheme.caption,
          children: <TextSpan>[
            TextSpan(
                text: '\n${curRiverlog.river.sectionName}',
                style: Theme.of(context).textTheme.subtitle1),
          ],
        ),
      ),
    );
  }

  Widget waterLevelGauge(RiverlogShortModel curRiverlog, BuildContext context) {
    try {
      var maxUnits = curRiverlog.river.maxFlow - curRiverlog.river.minFlow;
      var currentUnit =
          (curRiverlog.waterLevel - curRiverlog.river.minFlow) / maxUnits;
      return SizedBox(
        height: 30,
        width: 150,
        child: LiquidLinearProgressIndicator(
          value: currentUnit,
          valueColor: AlwaysStoppedAnimation(Theme.of(context).accentColor),
          backgroundColor: Theme.of(context).backgroundColor,
          borderColor: Theme.of(context).primaryColor,
          borderWidth: 5.0,
          borderRadius: 12.0,
          direction: Axis.horizontal,
          center: Text(
            '${curRiverlog.waterLevel}/${curRiverlog.river.maxFlow} ${curRiverlog.river.gaugeUnit}',
            style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: Colors.black),
          ),
        ),
      );
    } catch (exception) {
      return Text('');
    }
  }
}
