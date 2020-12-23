import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_list_view/group_list_view.dart';
import 'package:intl/intl.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:yvrkayakers/blocs/riverlog/index.dart';
import 'package:yvrkayakers/widgets/user_experience_card.dart';
import 'package:yvrkayakers/widgets/widgets.dart';

class RiverlogScreen extends StatefulWidget {
  final String _selectedUserId;
  RiverlogScreen(this._selectedUserId);
  @override
  RiverlogScreenState createState() {
    return RiverlogScreenState();
  }
}

class RiverlogScreenState extends State<RiverlogScreen> {
  RiverlogScreenState();
  RiverlogBloc _riverlogBloc;
  @override
  void initState() {
    super.initState();
    _riverlogBloc = RiverlogBloc(widget._selectedUserId);
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
            stream: _riverlogBloc.allRiverlogs.stream,
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
              tempData.sort((a, b) => b.logDateStart.compareTo(a.logDateStart));
              var newGroupedData = groupBy(
                  tempData,
                  (RiverlogShortModel obj) =>
                      DateFormat.yMMMM().format(obj.logDateStart));
              return Column(children: [
                UserExperienceCard(),
                RiverlogList(
                    newGroupedData: newGroupedData,
                    selectedUserId: widget._selectedUserId),
                Text('')
              ]);
            }));
  }

  void _load([bool isError = false]) {
    _riverlogBloc.initStream();
  }
}

class RiverlogList extends StatelessWidget {
  const RiverlogList(
      {Key key, @required this.newGroupedData, @required this.selectedUserId})
      : super(key: key);
  final String selectedUserId;
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
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
            child: Text(
              newGroupedData.keys.toList()[section].toString(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          );
        },
        separatorBuilder: (context, index) => SizedBox(height: 2),
        sectionSeparatorBuilder: (context, section) => SizedBox(height: 2),
        itemBuilder: (BuildContext context, IndexPath index) {
          var curRiver =
              newGroupedData[newGroupedData.keys.toList()[index.section]]
                  [index.index];
          return GestureDetector(
            onTap: () {
              //goToRiverlogDetail(curRiver.id, context);
            },
            child: Card(
              elevation: 5,
              child: Padding(
                padding: EdgeInsets.all(2),
                child: Stack(children: <Widget>[
                  Align(
                    alignment: Alignment.centerRight,
                    child: Stack(
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.only(left: 5, top: 2),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                          color:
                                              Theme.of(context).backgroundColor,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0))),
                                      child: Column(
                                        children: [
                                          Container(
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  5.0),
                                                          topRight:
                                                              Radius.circular(
                                                                  5.0))),
                                              width: 40.0,
                                              alignment: Alignment(0.0, 0.0),
                                              child: Text(
                                                '${DateFormat('E').format(curRiver.logDateStart)}',
                                                style: TextStyle(
                                                    fontSize: 15.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              )),
                                          Container(
                                              width: 40.0,
                                              // color: Colors.lightBlue,
                                              alignment: Alignment(0.0, 0.0),
                                              child: Text(
                                                '${DateFormat.d().format(curRiver.logDateStart)}',
                                                style: TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                              ))
                                        ],
                                      ),
                                    ),
                                    RiverGradeMedal(curRiver.river),
                                    riverNameSymbol(curRiver, context),
                                    Spacer(),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          children: [
                                            (curRiver.didSwim == true)
                                                ? FaIcon(
                                                    FontAwesomeIcons.swimmer,
                                                    color: Colors.red,
                                                    size: 14.0)
                                                : Text(''),
                                            (curRiver.didRescue == true)
                                                ? FaIcon(
                                                    FontAwesomeIcons.lifeRing,
                                                    size: 14.0,
                                                    color: Colors.green,
                                                  )
                                                : Text(''),
                                            Text(
                                              '@${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(curRiver.logDateStart))}',
                                              style: TextStyle(
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                            ),
                                          ],
                                        ),
                                        waterLevelGauge(curRiver, context)
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ))
                      ],
                    ),
                  )
                ]),
              ),
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
        width: 120,
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

  void goToRiverlogDetail(String curRiverlogId, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) {
        return MultiBlocProvider(providers: [
          BlocProvider<RiverlogBloc>.value(
            value: BlocProvider.of<RiverlogBloc>(context),
          ),
        ], child: RiverlogDetailPage(selectedUserId, curRiverlogId));
      }),
    );
  }
}
