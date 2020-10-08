import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:yvrkayakers/blocs/auth/index.dart';
import 'package:yvrkayakers/common/common_bloc.dart';
import 'package:yvrkayakers/generated/l10n.dart';

class HomeScreen extends StatefulWidget {
  final String name;

  HomeScreen(this.name);
  @override
  HomeScreenState createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final delegate = S.of(context);
    // set user stream
    CommonBloc.of(context).initStream();

    return Scaffold(
        appBar: AppBar(
          title: Text('YVRKayakers'),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.contacts,
              ),
              onPressed: () {
                //_goToContactScreen(context);
              },
            ),
            IconButton(
              icon: FaIcon(FontAwesomeIcons.infoCircle),
              onPressed: () {
                // go to about page
                PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
                  //String appName = packageInfo.appName;
                  //String packageName = packageInfo.packageName;
                  String version = packageInfo.version;
                  //String buildNumber = packageInfo.buildNumber;
                  showAboutDialog(
                      context: context,
                      applicationName: 'YVRKayakers',
                      applicationVersion: version);
                });
              },
            ),
            IconButton(
              icon: Icon(FontAwesomeIcons.signOutAlt),
              onPressed: () {
                // confirm before sign out
                showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: Text(delegate.signOutLabel + '?'),
                        actions: <Widget>[
                          FlatButton(
                            onPressed: () {
                              BlocProvider.of<AuthBloc>(context).add(
                                LoggedOutEvent(),
                              );
                              Navigator.of(context).pop();
                            },
                            child: Text(delegate.yesButton),
                          ),
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(delegate.noButton),
                          ),
                        ],
                      );
                    },
                    barrierDismissible: false);
              },
            )
          ],
        ),
        body: Text('Nothing here'));
  }
}
