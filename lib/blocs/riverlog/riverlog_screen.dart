import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';
import 'package:yvrkayakers/blocs/riverlog/index.dart';
import 'package:yvrkayakers/blocs/riverlog/riverlog_add_page.dart';
import 'package:yvrkayakers/common/common_functions.dart';

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
        child: Column(children: [
      StreamBuilder(
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
            return LimitedBox(
                maxHeight: 480,
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      var curRiver = snapshot.data[index];
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
                                      padding: const EdgeInsets.only(
                                          left: 5, top: 5),
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
                                                      color: Colors.teal,
                                                    ),
                                                    Text(
                                                      " ${DateFormat.yMMMd().format(curRiver.logDate)}",
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
                                              riverIcon(curRiver),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              riverNameSymbol(curRiver),
                                              Spacer(),
                                              riverChange(curRiver),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              riverChangeIcon(),
                                              SizedBox(
                                                width: 20,
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
                      );
                    }));

            return Center(
              child: CircularProgressIndicator(),
            );
          })
    ]));
  }

  void _load([bool isError = false]) {
    var session = FlutterSession();
    session.get("currentUserId").then((value) {
      BlocProvider.of<RiverlogBloc>(context)
          .add(LoadUserRiverlogEvent(value.toString()));
    });
  }

  Widget riverIcon(RiverlogModel curRiver) {
    return Padding(
        padding: const EdgeInsets.only(left: 0, right: 5.0),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
                alignment: Alignment.center,
                height: 60.0,
                width: 60.0,
                decoration: new BoxDecoration(
                    color: Colors.black87,
                    borderRadius: new BorderRadius.circular(10.0)),
                child: Text(
                  CommonFunctions.translateRiverDifficulty(
                      curRiver.riverDifficulty),
                  style: TextStyle(fontSize: 40, color: Colors.amber),
                ))));
  }

  Widget riverNameSymbol(RiverlogModel curRiver) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: curRiver.riverName,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
          children: <TextSpan>[
            TextSpan(
                text: '\n${curRiver.sectionName}',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget riverChange(RiverlogModel curRiver) {
    return Align(
      alignment: Alignment.topRight,
      child: RichText(
        text: TextSpan(
          text: '${curRiver.waterLevel.toString()} ${curRiver.gaugeUnit}',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.green, fontSize: 15),
          children: <TextSpan>[
            TextSpan(
                text: '\n${curRiver.minFlow}/${curRiver.maxFlow}',
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget riverChangeIcon() {
    return Align(
        alignment: Alignment.topRight,
        child: Icon(
          FontAwesomeIcons.arrowCircleUp,
          color: Colors.green,
          size: 30,
        ));
  }
}
