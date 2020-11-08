import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';

/// generate by https://javiercbk.github.io/json_to_dart/
class AutogeneratedTrip {
  final List<TripModel> results;

  AutogeneratedTrip({this.results});

  factory AutogeneratedTrip.fromJson(Map<String, dynamic> json) {
    List<TripModel> temp;
    if (json['results'] != null) {
      temp = <TripModel>[];
      json['results'].forEach((v) {
        temp.add(TripModel.fromJson(v as Map<String, dynamic>));
      });
    }
    return AutogeneratedTrip(results: temp);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (results != null) {
      data['results'] = results.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TripModel extends Equatable {
  final String id;

  final RiverbetaShortModel river;

  final DateTime tripDate;
  final String note;

  final String startByUserId;

  final List<TripParticipant> participants;

  TripModel(this.id, this.river, this.tripDate, this.note, this.participants,
      this.startByUserId);

  @override
  List<Object> get props =>
      [id, river, tripDate, note, participants, startByUserId];

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
        null, //json['id'] as String,
        RiverbetaShortModel.fromFire(json['river']),
        json['tripDate'] as DateTime,
        json['meetingPlace'] as String,
        TripParticipant.fromJson(json['participants']) as List<TripParticipant>,
        json['startedByUserId'] as String);
  }
  factory TripModel.fromFire(DocumentSnapshot doc) {
    var json = doc.data();
    return TripModel(
        doc.id,
        RiverbetaShortModel.fromJson(json['river']),
        json['tripDate'] as DateTime,
        json['meetingPlace'] as String,
        TripParticipant.fromJson(json['participants']) as List<TripParticipant>,
        json['startedByUserId'] as String);
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['river'] = river.toJson();
    data['tripDate'] = tripDate;
    data['meetingPlace'] = note;
    data['participants'] = participants.map((e) => e.toJson()).toList();
    data['startByUserId'] = startByUserId;
    return data;
  }
}

class TripParticipant extends Equatable {
  final String userId;
  final String userDisplayName;
  final bool needRide;
  final int availableSpace;

  TripParticipant(
      this.userId, this.userDisplayName, this.needRide, this.availableSpace);

  @override
  List<Object> get props => [userId, userDisplayName, needRide, availableSpace];

  factory TripParticipant.fromJson(Map<String, dynamic> json) {
    return TripParticipant(
        json['userId'] as String,
        json['userDisplayName'] as String,
        json['needRide'] as bool,
        json['availableSpace'] as int);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['userId'] = userId;
    data['userDisplayName'] = userDisplayName;
    data['needRide'] = needRide;
    data['availableSpace'] = availableSpace;
    return data;
  }
}
