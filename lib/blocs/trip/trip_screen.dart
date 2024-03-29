import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_list_view/group_list_view.dart';
import 'package:intl/intl.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';
import 'package:yvrkayakers/blocs/trip/index.dart';
import 'package:yvrkayakers/blocs/trip/trip_detail_page.dart';
import 'package:yvrkayakers/common/common_functions.dart';

import 'package:yvrkayakers/blocs/auth/index.dart';
import 'package:yvrkayakers/widgets/widgets.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({
    Key key,
    @required TripBloc tripBloc,
  })  : _tripBloc = tripBloc,
        super(key: key);

  final TripBloc _tripBloc;

  @override
  TripScreenState createState() {
    return TripScreenState();
  }
}

class TripScreenState extends State<TripScreen> {
  TripScreenState();

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
        child: Column(children: [
      StreamBuilder(
          stream: BlocProvider.of<TripBloc>(context).allNewTrips.stream,
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
            List<TripModel> tempData = snapshot.data;
            var newGroupedData = groupBy(tempData,
                (TripModel obj) => DateFormat.yMMMd().format(obj.tripDate));

            return GroupListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              sectionsCount: newGroupedData.length,
              countOfItemInSection: (int section) {
                return newGroupedData[newGroupedData.keys.toList()[section]]
                    .length;
              },
              itemBuilder: (BuildContext context, IndexPath index) {
                var curTrip =
                    newGroupedData[newGroupedData.keys.toList()[index.section]]
                        [index.index];
                return GestureDetector(
                    onTap: () {
                      goToTripDetail(curTrip);
                    },
                    child: Card(
                        elevation: 5,
                        color: (curTrip.participants.any((element) =>
                                element.userId ==
                                BlocProvider.of<AuthBloc>(context)
                                    .currentAuth
                                    .value
                                    .uid)
                            ? Colors.blue.shade100
                            : Colors.white),
                        child: Padding(
                          padding: EdgeInsets.all(2),
                          child: Stack(children: <Widget>[
                            Align(
                              alignment: Alignment.centerRight,
                              child: Stack(
                                children: <Widget>[
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5, top: 2),
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Container(
                                                child: Row(
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.timer,
                                                      size: 18.0,
                                                      color: Colors.teal,
                                                    ),
                                                    Text(
                                                      "${DateFormat.Hm().format(curTrip.tripDate)}",
                                                      style: TextStyle(
                                                          color: Colors.teal,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18.0),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              RiverGradeBadge(curTrip.river),
                                              riverNameSymbol(curTrip.river),
                                              Spacer(),
                                              Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      participantsList(curTrip),
                                                      riverChangeIcon(curTrip),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      FaIcon(
                                                          FontAwesomeIcons
                                                              .comments,
                                                          size: 20,
                                                          color: Colors.blue),
                                                      Text(curTrip.commentCount
                                                          .toString()),
                                                    ],
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                          Container(
                                              height: 50.0,
                                              child: ListView.builder(
                                                itemCount:
                                                    curTrip.participants.length,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemBuilder: (context, index) {
                                                  return CircleAvatar(
                                                    radius: 20.0,
                                                    backgroundColor:
                                                        Colors.grey[200],
                                                    backgroundImage:
                                                        CachedNetworkImageProvider(
                                                            curTrip
                                                                .participants[
                                                                    index]
                                                                .userPhotoUrl),
                                                  );
                                                },
                                              ))
                                        ],
                                      ))
                                ],
                              ),
                            )
                          ]),
                        )));
              },
              groupHeaderBuilder: (BuildContext context, int section) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                  child: Text(
                    newGroupedData.keys.toList()[section].toString(),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                );
              },
              separatorBuilder: (context, index) => SizedBox(height: 2),
              sectionSeparatorBuilder: (context, section) =>
                  SizedBox(height: 2),
            );
          }),
      Text('')
    ]));
  }

  void _load([bool isError = false]) {
    widget._tripBloc.add(LoadTripEvent(isError));
  }

  Widget riverNameSymbol(RiverbetaShortModel curRiver) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: curRiver.riverName,
          style: Theme.of(context).textTheme.caption,
          children: <TextSpan>[
            TextSpan(
                text: '\n${curRiver.sectionName}',
                style: Theme.of(context).textTheme.subtitle1),
          ],
        ),
      ),
    );
  }

  Widget participantsList(TripModel curTrip) {
    var supportCount = 0;
    var newbieCount = 0;
    curTrip.participants.forEach((element) {
      if (element.skillLevel >= curTrip.river.difficulty) {
        supportCount++;
      } else if (element.skillLevel < curTrip.river.difficulty) {
        newbieCount++;
      }
    });

    var startBy = curTrip.startByUserId;
    return Align(
      alignment: Alignment.topRight,
      child: RichText(
        text: TextSpan(
            text: '${supportCount.toString()}',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.green, fontSize: 20),
            children: [
              WidgetSpan(
                child: Icon(Icons.person, size: 20, color: Colors.green),
              ),
              TextSpan(
                  text: '${newbieCount.toString()}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 20),
                  children: [
                    WidgetSpan(
                      child: Icon(Icons.person, size: 20, color: Colors.red),
                    ),
                  ]),
            ]),
      ),
    );
  }

  Widget riverChangeIcon(TripModel curTrip) {
    var tripBalance = 0;
    curTrip.participants.forEach((element) {
      if (element.skillLevel > curTrip.river.difficulty) {
        tripBalance++;
      } else if (element.skillLevel < curTrip.river.difficulty) {
        tripBalance--;
      }
    });
    if (tripBalance >= 0) {
      return Align(
          alignment: Alignment.topRight,
          child: Icon(
            FontAwesomeIcons.thumbsUp,
            color: Colors.green,
            size: 20,
          ));
    } else if (tripBalance < 0) {
      return Align(
          alignment: Alignment.topRight,
          child: Icon(
            FontAwesomeIcons.exclamationCircle,
            color: Colors.red,
            size: 20,
          ));
    }
  }

  void goToTripDetail(TripModel curTrip) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) {
        return MultiBlocProvider(providers: [
          BlocProvider<TripBloc>.value(
            value: BlocProvider.of<TripBloc>(context),
          ),
        ], child: TripDetailPage(curTrip));
      }),
    );
  }
}
