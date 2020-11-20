import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';
import 'package:yvrkayakers/blocs/riverlog/index.dart';
import 'package:yvrkayakers/blocs/riverlog/riverlog_add_page.dart';
import 'package:yvrkayakers/blocs/trip/trip_add_page.dart';
import 'package:intl/intl.dart';
import 'package:yvrkayakers/common/myconstants.dart';

class RiverbetaDetailPage extends StatefulWidget {
  String _currentRiverId;
  RiverbetaDetailPage(this._currentRiverId);
  @override
  RiverbetaDetailPageState createState() {
    return RiverbetaDetailPageState();
  }
}

class RiverbetaDetailPageState extends State<RiverbetaDetailPage> {
  RiverbetaDetailPageState();

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
    return BlocBuilder<RiverbetaBloc, RiverbetaState>(builder: (
      BuildContext context,
      RiverbetaState currentState,
    ) {
      if (currentState is UnRiverbetaState) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      if (currentState is ErrorRiverbetaState) {
        return SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(currentState.errorMessage ?? 'Error'),
            Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: RaisedButton(
                color: Colors.blue,
                child: Text('reload'),
                onPressed: _load,
              ),
            ),
          ],
        ));
      }
      if (currentState is InRiverbetaState) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(currentState.hello),
              Text('Flutter files: done'),
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: RaisedButton(
                  color: Colors.red,
                  child: Text('throw error'),
                  onPressed: () => _load(true),
                ),
              ),
            ],
          ),
        );
      }
      if (currentState is FoundRiverbetaState) {
        var foundRiver = currentState.foundRiver;
        var foundRiverStat = currentState.foundRiverStat;

        return Scaffold(
            appBar: AppBar(
              title: Text(foundRiver.riverName),
            ),
            body: SingleChildScrollView(
                child: Column(
              children: [
                Text(foundRiver.riverName,
                    style: Theme.of(context).textTheme.headline1),
                Text(foundRiver.sectionName,
                    style: Theme.of(context).textTheme.headline2),
                Text('Difficulty: ' + foundRiver.difficulty.toString()),
                Text('Level: ' +
                    foundRiver.minFlow.toString() +
                    ' to ' +
                    foundRiver.maxFlow.toString() +
                    ' ' +
                    foundRiver.gaugeUnit),
                Text('Total Runs:' + foundRiverStat.entries.length.toString()),
                Text('Total Paddlers:' +
                    foundRiverStat.visitors.length.toString()),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RaisedButton(
                        onPressed: () {
                          goToAddRiverLogPage(foundRiver);
                        },
                        child: Text("Add New Log"),
                      ),
                      RaisedButton(
                        onPressed: () {
                          goToAddTripPage(foundRiver);
                        },
                        child: Text("Make New Trip"),
                      )
                    ]),
                Text("#" + foundRiver.riverHashtag()),
                FutureBuilder(
                  future: hashtagYoutubeVDO(foundRiver),
                  builder:
                      (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                    if (snapshot.data == null) {
                      return Text("...Loading...");
                    }
                    return snapshot.data;
                  },
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: foundRiverStat.entries.length,
                  itemBuilder: (context, index) {
                    var paddler = foundRiverStat.visitors.firstWhere(
                        (element) =>
                            element.id == foundRiverStat.entries[index].userId);
                    return Text('Paddled by ' +
                        paddler.displayName +
                        ' on ' +
                        DateFormat.yMMMd()
                            .format(foundRiverStat.entries[index].logDate));
                  },
                ),
                Text('')
              ],
            )));
      }
      return Center(
        child: CircularProgressIndicator(),
      );
    });
  }

  void _load([bool isError = false]) {
    //widget._riverbetaBloc.add(LoadRiverbetaEvent(isError));

    BlocProvider.of<RiverbetaBloc>(context)
        .add(FetchingRiverbetaEvent(this.widget._currentRiverId));
  }

  Future<Widget> hashtagYoutubeVDO(RiverbetaShortModel foundRiver) async {
    String key = await MyConstants.googleApiKey();
    YoutubeAPI ytApi = new YoutubeAPI(key);
    List<YT_API> ytResult = [];
    String query = "#" + foundRiver.riverHashtag();
    var value = await ytApi.search(query);
    if (value.length == 0) {
      //then try hashtag for normal river
      value =
          await ytApi.search("#" + foundRiver.riverName.replaceAll(" ", ""));
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: value.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Image.network(value[index].thumbnail['default']['url']),
            Text(value[index].title),
            Text('by ' + value[index].channelTitle),
          ],
        );
      },
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
    );

// data which are available in ytResult are shown below
    // return LimitedBox(
    //   maxHeight: 300.0,
    //   child: WebView(
    //       initialUrl:
    //           'https://www.youtube.com/results?search_query=%23capilanoriver'),
    // );
  }

  void goToAddRiverLogPage(RiverbetaModel foundRiver) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) {
        return MultiBlocProvider(providers: [
          BlocProvider.value(
            value: BlocProvider.of<RiverlogBloc>(context),
          ),
          BlocProvider.value(
            value: BlocProvider.of<RiverbetaBloc>(context),
          ),
        ], child: RiverlogAddPage(foundRiver));
      }),
    );
  }

  void goToAddTripPage(RiverbetaModel foundRiver) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) {
        return MultiBlocProvider(providers: [
          BlocProvider.value(
            value: BlocProvider.of<RiverlogBloc>(context),
          ),
          BlocProvider.value(
            value: BlocProvider.of<RiverbetaBloc>(context),
          ),
        ], child: TripAddPage(foundRiver));
      }),
    );
  }
}
