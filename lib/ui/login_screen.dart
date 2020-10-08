import 'package:flutter/material.dart';
import 'package:yvrkayakers/ui/login_form.dart';

class LoginScreen extends StatefulWidget {
  static String route = 'login';

  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: LoginForm(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
