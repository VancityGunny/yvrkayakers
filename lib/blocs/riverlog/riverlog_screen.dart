import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_list_view/group_list_view.dart';
import 'package:intl/intl.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';
import 'package:yvrkayakers/blocs/riverlog/index.dart';
import 'package:yvrkayakers/blocs/riverlog/riverlog_add_page.dart';
import 'package:yvrkayakers/blocs/user/user_model.dart';
import 'package:yvrkayakers/common/common_functions.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

              List<RiverlogModel> tempData = snapshot.data;
              var newGroupedData = groupBy(tempData,
                  (RiverlogModel obj) => DateFormat.yMMM().format(obj.logDate));
              return Column(children: [
                UserExperienceCard(tempData),
                RiverlogList(newGroupedData: newGroupedData)
              ]);
            }));
  }

  void _load([bool isError = false]) {
    var session = FlutterSession();
    session.get("currentUserId").then((value) {
      BlocProvider.of<RiverlogBloc>(context)
          .add(LoadUserRiverlogEvent(value.toString()));
    });
  }
}

class UserExperienceCard extends StatelessWidget {
  List<RiverlogModel> _riverlogs;
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
                    Text(
                      currentUser.displayName,
                      style: TextStyle(fontSize: 30.0),
                    ),
                    Text("Favorite: " +
                        currentUser.userStat.favoriteRiver.riverName),
                    Text("Last Paddle: " +
                        DateFormat.yMMMd()
                            .format(currentUser.userStat.lastWetness)),
                  ],
                )
              ],
            ),
            LimitedBox(
                maxHeight: 20.0,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: groupExperience.length,
                  itemBuilder: (context, index) {
                    var gradeLabel = CommonFunctions.translateRiverDifficulty(
                        groupExperience.keys.elementAt(index));
                    return Text('Class:' +
                        gradeLabel +
                        " (" +
                        groupExperience.values.elementAt(index).toString() +
                        ")");
                  },
                ))
          ]);
        });
  }
}

class RiverlogList extends StatelessWidget {
  const RiverlogList({
    Key key,
    @required this.newGroupedData,
  }) : super(key: key);

  final Map<String, List<RiverlogModel>> newGroupedData;

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
                                  Container(
                                    child: Row(
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
                                                .subtitle2)
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  riverGradeIcon(curRiver),
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

  Widget riverGradeIcon(RiverlogModel curRiver) {
    return Container(
        alignment: Alignment.topLeft,
        child: Text(
          CommonFunctions.translateRiverDifficulty(curRiver.river.difficulty),
          style: TextStyle(fontSize: 20, color: Colors.black),
        ));
  }

  Widget riverNameSymbol(RiverlogModel curRiverlog, BuildContext context) {
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

  Widget waterLevelGauge(RiverlogModel curRiverlog, BuildContext context) {
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
