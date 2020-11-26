import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:yvrkayakers/blocs/auth/index.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';
import 'package:yvrkayakers/blocs/riverlog/index.dart';
import 'package:yvrkayakers/blocs/trip/trip_bloc.dart';
import 'package:yvrkayakers/blocs/trip/trip_page.dart';
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
  RiverbetaBloc _riverbetaBloc = new RiverbetaBloc();
  RiverlogBloc _riverlogBloc = new RiverlogBloc();
  TripBloc _tripBloc = new TripBloc();
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
    _riverbetaBloc.initStream();
    _riverlogBloc.initStream();
    _tripBloc.initStream();
    BlocProvider.of<AuthBloc>(context).initStream();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('YVRKayakers'),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.list,
              ),
              onPressed: () {
                //_goToRiverbetaScreen(context);
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
        body: MultiBlocProvider(
          providers: [
            BlocProvider<RiverbetaBloc>.value(
              value: _riverbetaBloc,
            ),
            BlocProvider<RiverlogBloc>.value(
              value: _riverlogBloc,
            ),
            BlocProvider<TripBloc>.value(
              value: _tripBloc,
            ),
          ],
          child: Center(
            child: PersistentTabView(
              controller: _controller,
              screens: _navScreens(),
              items: _navBarsItems(),
              confineInSafeArea: true,
              backgroundColor: Colors.white,
              handleAndroidBackButtonPress: true,
              resizeToAvoidBottomInset: true,
              hideNavigationBarWhenKeyboardShows: true,
              decoration: NavBarDecoration(
                borderRadius: BorderRadius.circular(10.0),
              ),
              popAllScreensOnTapOfSelectedTab: true,
              navBarStyle: NavBarStyle.style9,
            ),
          ),
        ));
  }

  PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);
  List<Widget> _navScreens() {
    return [RiverbetaPage(), RiverlogPage(), TripPage()];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: FaIcon(FontAwesomeIcons.water),
        title: ("Rivers"),
        activeColor: CupertinoColors.activeBlue,
        inactiveColor: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: FaIcon(FontAwesomeIcons.book),
        title: ("Logbook"),
        activeColor: CupertinoColors.activeGreen,
        inactiveColor: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: FaIcon(FontAwesomeIcons.calendarAlt),
        title: ("Trip"),
        activeColor: CupertinoColors.systemRed,
        inactiveColor: CupertinoColors.systemGrey,
      )
    ];
  }
}
