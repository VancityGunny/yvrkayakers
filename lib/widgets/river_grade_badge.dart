import 'package:flutter/material.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';
import 'package:yvrkayakers/common/common_functions.dart';

import 'package:yvrkayakers/blocs/user/user_model.dart';

class RiverGradeMedal extends StatelessWidget {
  RiverbetaShortModel _curRiver;
  RiverGradeMedal(this._curRiver);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        padding: EdgeInsets.all(2.0),
        child: Container(
            alignment: Alignment.center,
            height: 22.0,
            width: 22.0,
            decoration: new BoxDecoration(
                color: CommonFunctions.translateRiverDifficultyColor(
                    _curRiver.difficulty),
                borderRadius: new BorderRadius.circular(10.0)),
            child: Text(
              CommonFunctions.translateRiverDifficulty(_curRiver.difficulty),
              style: TextStyle(fontSize: 15, color: Colors.white),
            )));
  }
}

class UserSkillMedal extends StatelessWidget {
  double _curSkillLevel;
  UserSkillMedal(this._curSkillLevel);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        padding: EdgeInsets.all(2.0),
        child: Container(
            alignment: Alignment.center,
            height: 22.0,
            width: 22.0,
            decoration: new BoxDecoration(
                color: CommonFunctions.translateRiverDifficultyColor(
                    _curSkillLevel),
                borderRadius: new BorderRadius.circular(10.0)),
            child: Text(
              CommonFunctions.translateRiverDifficulty(_curSkillLevel),
              style: TextStyle(fontSize: 15, color: Colors.white),
            )));
  }
}

class RiverGradeIcon extends StatelessWidget {
  double _riverGrade;
  RiverGradeIcon(this._riverGrade);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        alignment: Alignment.center,
        height: 18.0,
        width: 18.0,
        decoration: new BoxDecoration(
            color: Colors.blue, borderRadius: new BorderRadius.circular(2.0)),
        child: Text(
          CommonFunctions.translateRiverDifficulty(_riverGrade),
          style: TextStyle(fontSize: 12, color: Colors.white),
        ));
  }
}

class RiverGradeBadge extends StatelessWidget {
  RiverbetaShortModel _curRiver;
  RiverGradeBadge(this._curRiver);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        alignment: Alignment.center,
        height: 60.0,
        width: 60.0,
        decoration: new BoxDecoration(
            color: Colors.black87,
            borderRadius: new BorderRadius.circular(10.0)),
        child: Text(
          CommonFunctions.translateRiverDifficulty(_curRiver.difficulty),
          style: TextStyle(fontSize: 40, color: Colors.amber),
        ));
  }
}
