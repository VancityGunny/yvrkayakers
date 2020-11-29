import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:yvrkayakers/blocs/auth/index.dart';
import 'package:yvrkayakers/generated/l10n.dart';

class UserNameSelectionScreen extends StatefulWidget {
  @override
  UserNameSelectionScreenState createState() => UserNameSelectionScreenState();
}

class UserNameSelectionScreenState extends State<UserNameSelectionScreen> {
  String _userName;
  final _formKey = GlobalKey<FormState>();
  bool _isInAsyncCall = false;
  bool _isInvalidAsyncUser = false; // if user name is not available
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("UserName Selection")),
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: ModalProgressHUD(
              inAsyncCall: _isInAsyncCall,
              // demo of some additional parameters
              opacity: 0.5,
              progressIndicator: CircularProgressIndicator(),
              child: Form(
                  key: _formKey,
                  child: Center(
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      child: SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(30.0, 40.0, 30.0, 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                // width: 200.0,
                                // height: 350.0,
                                margin: EdgeInsets.only(bottom: 40.0),
                                child: Image(
                                  image: AssetImage(
                                    'graphics/authentication.png',
                                  ),
                                ),
                              ),
                              Container(
                                height: 50.0,
                                child: Theme(
                                  data: ThemeData(
                                    primaryColor: Colors.grey,
                                  ),
                                  child: TextFormField(
                                    onSaved: (value) =>
                                        _userName = value.toLowerCase(),
                                    textCapitalization: TextCapitalization.none,
                                    validator: _validateUserName,
                                    decoration: InputDecoration(
                                      labelText: "Choose UserName ",
                                      hintText:
                                          "Must be 5 characters or longer, alphanumeric only",
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: RaisedButton(
                                  onPressed: _submit,
                                  child: Text('Save UserName'),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ))),
        ));
  }

  Future<void> updateUserName(_userName) async {
    BlocProvider.of<AuthBloc>(context).add(
      ChooseUserNameEvent(_userName),
    );
  }

  Future<bool> isUserNameExists(String value) async {
    var authRepo = new AuthRepository();
    return authRepo.isUserNameExists(value);
  }

  String _validateUserName(String selectedUserName) {
    if (selectedUserName.isEmpty) {
      return 'Please enter some text';
    }
    if (selectedUserName.length < 5 || selectedUserName.length > 16) {
      return 'Please limit username between 5-16 characters';
    }
    // check duplication

    if (_isInvalidAsyncUser) {
      _isInvalidAsyncUser = false;
      return 'This username already exists.';
    }
    return null;
  }

  void _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      // dismiss keyboard during async call
      FocusScope.of(context).requestFocus(new FocusNode());

      // start the modal progress HUD
      setState(() {
        _isInAsyncCall = true;
      });

      isUserNameExists(_userName).then((isAlreadyExist) {
        if (isAlreadyExist) {
          // show error
          _isInvalidAsyncUser = true;
        } else {
          _isInvalidAsyncUser = false;
          updateUserName(_userName);
        }
        setState(() {
          _isInAsyncCall = false;
        });
      });
    }
  }
}
