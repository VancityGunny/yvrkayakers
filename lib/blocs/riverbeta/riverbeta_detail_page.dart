import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';
import 'package:yvrkayakers/blocs/riverlog/index.dart';
import 'package:yvrkayakers/blocs/riverlog/riverlog_add_page.dart';
import 'package:yvrkayakers/blocs/trip/trip_add_page.dart';
import 'package:yvrkayakers/blocs/hashtag/index.dart';
import 'package:yvrkayakers/common/myconstants.dart';
import 'package:yvrkayakers/widgets/widgets.dart';
import 'package:yvrkayakers/common/common_functions.dart';

import 'package:cached_network_image/cached_network_image.dart';

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
        var foundRiverHashtag = currentState.foundRiverHashtag;

        return Scaffold(
            appBar: AppBar(
              title: Text(foundRiver.riverName),
            ),
            body: SingleChildScrollView(
                child: Column(
              children: [
                Row(
                  children: [
                    RiverGradeBadge(foundRiver),
                    Text(foundRiver.riverName,
                        style: Theme.of(context).textTheme.headline1),
                  ],
                ),
                Text(foundRiver.sectionName,
                    style: Theme.of(context).textTheme.headline2),
                (foundRiver.minFlow == null)
                    ? Text('')
                    : Text('Level: ' +
                        foundRiver.minFlow.toString() +
                        ' to ' +
                        foundRiver.maxFlow.toString() +
                        ' ' +
                        foundRiver.gaugeUnit),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Total Runs:' +
                        foundRiverStat.entries.length.toString()),
                    Text('Total Paddlers:' +
                        foundRiverStat.visitors.length.toString()),
                  ],
                ),
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
                  future: hashtagYoutubeVDO(foundRiver, foundRiverHashtag),
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
                            element.uid == foundRiverStat.entries[index].uid,
                        orElse: () => null);
                    if (paddler == null) {
                      return Text('');
                    }
                    return Row(children: [
                      GestureDetector(
                        onTap: () {
                          goToUserRiverlogPage(paddler.uid);
                        },
                        child: CircleAvatar(
                          radius: 20.0,
                          backgroundColor: Colors.grey[200],
                          backgroundImage:
                              CachedNetworkImageProvider(paddler.photoUrl),
                        ),
                      ),
                      Text('Paddled by ' +
                          paddler.displayName +
                          ' ' +
                          CommonFunctions.formatDateForDisplay(
                              foundRiverStat.entries[index].logDate))
                    ]);
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

  Future<Widget> hashtagYoutubeVDO(
      RiverbetaModel foundRiver, HashtagModel foundRiverHashtag) async {
    try {
      List<ExtObjectLink> newSampleVideos;
      //get to see what hashtag we have

      //only fetch if it's older than 1 week
      if (foundRiverHashtag.lastFetchVideos != null &&
          DateTime.now().isBefore(
              foundRiverHashtag.lastFetchVideos.add(Duration(days: 7)))) {
        newSampleVideos = foundRiverHashtag.relatedVideos;
      } else {
        String key = await MyConstants.googleApiKey();
        YoutubeAPI ytApi = new YoutubeAPI(key);
        String query = "#" + foundRiverHashtag.hashtag;
        var value = await ytApi.search(query);
        if (value.length == 0) {
          //then try hashtag for normal river
          value = await ytApi
              .search("#" + foundRiver.riverName.replaceAll(" ", ""));
        }

        newSampleVideos = value
            .map((e) => new ExtObjectLink(
                e.thumbnail['default']['url'], e.title, e.url))
            .toList();
      }

      // update the fetch videos
      BlocProvider.of<RiverbetaBloc>(context).add(
          new UpdatingVideosRiverbetaEvent(
              foundRiverHashtag.hashtag, newSampleVideos));

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: newSampleVideos.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              FlatButton(
                  onPressed: () async {
                    var url = newSampleVideos[index].url;
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: Image.network(newSampleVideos[index].thumbnail)),
              Text(
                newSampleVideos[index].caption,
                overflow: TextOverflow.ellipsis,
              )
            ],
          );
        },
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
      );
    } catch (error) {
      return Text('');
    }
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

  void goToUserRiverlogPage(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) {
        return RiverlogPage(userId);
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
