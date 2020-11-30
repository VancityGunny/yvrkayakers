import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:yvrkayakers/ui/home_screen.dart';
import 'package:yvrkayakers/ui/login_screen.dart';
import 'package:yvrkayakers/ui/login_with_phone.dart';
import 'package:yvrkayakers/ui/splash_screen.dart';
import 'package:yvrkayakers/ui/username_selection_screen.dart';

import 'blocs/auth/index.dart';
import 'common/common_bloc.dart';
import 'generated/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await DotEnv().load('secrets.env');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AuthRepository _authRepository = AuthRepository();
  AuthBloc _authenticationBloc;

  @override
  void initState() {
    super.initState();

    _authenticationBloc = AuthBloc(authRepository: _authRepository);
    _authenticationBloc.add(AppStartedEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) =>
            _authenticationBloc, //bloc: _authenticationBloc,
        child: CommonBloc(
            child: MaterialApp(
          localizationsDelegates: [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate
          ],
          supportedLocales: S.delegate.supportedLocales,
          theme: ThemeData(
            // Define the default brightness and colors.
            // brightness: Brightness.dark,
            // primaryColor: Colors.blue[800],
            // accentColor: Colors.lightBlue[600],
            // backgroundColor: Colors.cyan[200],

            // Define the default font family.
            fontFamily: 'Georgia',

            // Define the default TextTheme. Use this to specify the default
            // text styling for headlines, titles, bodies of text, and more.
            textTheme: TextTheme(
                headline1:
                    TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold),
                headline2:
                    TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
                headline4:
                    TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal),
                headline6:
                    TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
                button: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                bodyText2: TextStyle(
                    fontSize: 14.0, fontFamily: 'Hind', color: Colors.black87),
                caption: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Hind'),
                subtitle1: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
                subtitle2: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontStyle: FontStyle.italic)),
          ),
          debugShowCheckedModeBanner: false,
          home: BlocBuilder(
            bloc: _authenticationBloc,
            builder: (BuildContext context, AuthState state) {
              final delegate = S.of(context);
              if (state is UnAuthState) {
                return SplashScreen();
              }
              if (state is UnauthenticatedAuthState) {
                return LoginScreen();
              }
              if (state is PhoneVerificationAuthState) {
                // now go do phone verification
                return LoginOTP();
              }
              if (state is UserNameVerificationAuthState) {
                return UserNameSelectionScreen();
              }
              if (state is AuthenticatedAuthState) {
                return HomeScreen(state.displayName);
              }
              if (state is LogInFailureAuthState) {
                return Scaffold(
                    body: Column(
                  children: [
                    Icon(Icons.error),
                    Text(
                      delegate.loginFailed,
                      style: TextStyle(fontSize: 30.0),
                    ),
                    Text(state.errorMessage, style: TextStyle(fontSize: 20.0)),
                  ],
                ));
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        )));
  }

  @override
  void dispose() {
    _authenticationBloc.close();
    super.dispose();
  }
}
