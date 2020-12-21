import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:yvrkayakers/blocs/auth/index.dart';
import 'package:yvrkayakers/blocs/user/user_model.dart';
import 'package:yvrkayakers/common/common_functions.dart';
import 'package:yvrkayakers/widgets/widgets.dart';

class UserExperienceCard extends StatelessWidget {
  UserExperienceCard();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: BlocProvider.of<AuthBloc>(context).currentAuth.stream,
        builder: (context, snapshot) {
          if (snapshot.data == null) return Text('');
          var currentUser = snapshot.data;
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        UserSkillMedal(currentUser.userSkill),
                        Text("@" + currentUser.userName,
                            style: Theme.of(context).textTheme.headline4),
                        Text('   '),
                        FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.yellow.shade900)),
                          color: Colors.yellow.shade700,
                          onPressed: () {
                            // copy hashtag to clipboard
                            var hashtag =
                                '#${CommonFunctions.getHashtag(user: currentUser)}';
                            FlutterClipboard.copy(hashtag).then((value) {
                              var snackBar = SnackBar(
                                  content: Text(hashtag +
                                      ' is copied to clipboard! Share vdo or photo of this paddler in social media using this hashtag.'));
                              Scaffold.of(context).showSnackBar(snackBar);
                            });
                          },
                          child: Text(
                              '#${CommonFunctions.getHashtag(user: currentUser)}',
                              style: TextStyle(fontSize: 12.0)),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Name: ",
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        Container(
                          padding: new EdgeInsets.only(right: 13.0),
                          child: new Text(currentUser.displayName,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.subtitle1),
                        )
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
