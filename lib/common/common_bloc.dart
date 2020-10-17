import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CommonBloc extends InheritedWidget {
  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  CommonBloc({Key key, Widget child}) : super(key: key, child: child);

  static CommonBloc of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CommonBloc>();
  }

  initStream() {}

  Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}
