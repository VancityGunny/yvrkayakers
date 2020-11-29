import 'package:flutter/material.dart';
import 'package:yvrkayakers/blocs/hashtag/index.dart';

class HashtagPage extends StatefulWidget {
  static const String routeName = '/hashtag';

  @override
  _HashtagPageState createState() => _HashtagPageState();
}

class _HashtagPageState extends State<HashtagPage> {
  final _hashtagBloc = HashtagBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hashtag'),
      ),
      body: HashtagScreen(hashtagBloc: _hashtagBloc),
    );
  }
}
