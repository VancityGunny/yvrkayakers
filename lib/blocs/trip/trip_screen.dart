import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';
import 'package:yvrkayakers/blocs/trip/index.dart';
import 'package:yvrkayakers/common/common_functions.dart';

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
          stream: BlocProvider.of<TripBloc>(context).allTrips.stream,
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
                      TripModel curTrip = snapshot.data[index];
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
                                          left: 10, top: 5),
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
                                                      "${curTrip.tripDate.toString()}",
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
                                              riverIcon(curTrip.river),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              riverNameSymbol(curTrip.river),
                                              Spacer(),
                                              participantsList(curTrip),
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
          })
    ]));
  }

  void _load([bool isError = false]) {
    widget._tripBloc.add(LoadTripEvent(isError));
  }

  Widget riverIcon(RiverbetaShortModel curRiver) {
    return Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
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
                  CommonFunctions.translateRiverDifficulty(curRiver.difficulty),
                  style: TextStyle(fontSize: 40, color: Colors.amber),
                ))));
  }

  Widget riverNameSymbol(RiverbetaShortModel curRiver) {
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

  Widget participantsList(TripModel curTrip) {
    return Align(
      alignment: Alignment.topRight,
      child: RichText(
        text: TextSpan(
          text: '${curTrip.participants.length.toString()}',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.green, fontSize: 20),
          children: <TextSpan>[
            TextSpan(
                text: '\n...',
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 15,
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
