import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yvrkayakers/blocs/trip/trip_model.dart';

class TripProvider {
  static final _firestore = FirebaseFirestore.instance;
  Future<void> loadAsync(String token) async {
    /// write from keystore/keychain
    await Future.delayed(Duration(seconds: 2));
  }

  Future<void> saveAsync(String token) async {
    /// write from keystore/keychain
    await Future.delayed(Duration(seconds: 2));
  }

  void test(bool isError) {
    if (isError == true) {
      throw Exception('manual error');
    }
  }

  Future<String> addTrip(TripModel newTrip) async {
    var newTripRef = _firestore.collection('/trips').doc(newTrip.id);
    newTripRef.set(newTrip.toJson());
    return newTrip.id;
  }

  Future<String> addTripComment(
      String tripId, TripCommentModel newComment) async {
    var foundTripRef = _firestore.collection('/trips').doc(tripId);
    var newTripCommentRef =
        _firestore.collection('/trips').doc(tripId).collection('/comments');
    var newCommentRef = newTripCommentRef.doc();
    newCommentRef.set(newComment.toJson());
    foundTripRef.update({'commentCount': FieldValue.increment(1)});
    return newCommentRef.id;
  }

  Future<String> addTripParticipant(
      String tripId, TripParticipantModel newTripParticipant) async {
    var foundTripRef = _firestore.collection('/trips').doc(tripId);
    var foundTripObj = await foundTripRef.get();

    List<TripParticipantModel> updatedParticipants = foundTripObj
        .data()['participants']
        .map<TripParticipantModel>((e) => TripParticipantModel.fromJson(e))
        .toList();
    updatedParticipants.add(newTripParticipant);
    foundTripRef.update(
        {'participants': updatedParticipants.map((e) => e.toJson()).toList()});

    //also update hidden participantids list too
    List<String> updatedParticipantIds = foundTripObj
        .data()['participantIds']
        .map<String>((e) => e.toString())
        .toList();
    updatedParticipantIds.add(newTripParticipant.userId);
    foundTripRef.update({'participantIds': updatedParticipantIds});
  }

  Future<void> removeTripParticipant(String tripId, String removeUserId) async {
    var foundTripRef = _firestore.collection('/trips').doc(tripId);
    var foundTripObj = await foundTripRef.get();
    List<TripParticipantModel> updatedParticipants = foundTripObj
        .data()['participants']
        .map<TripParticipantModel>((e) => TripParticipantModel.fromJson(e))
        .toList();
    updatedParticipants
        .removeWhere((element) => element.userId == removeUserId);

    if (updatedParticipants.length == 0) {
      // if no current participants then cancel this trip
      await foundTripRef.delete();
      return;
    }

    await foundTripRef.update(
        {'participants': updatedParticipants.map((e) => e.toJson()).toList()});

    //also remove hidden participantids list too
    List<String> updatedParticipantIds = foundTripObj
        .data()['participantIds']
        .map<String>((e) => e.toString())
        .toList();
    updatedParticipantIds.removeWhere((element) => element == removeUserId);
    await foundTripRef.update({'participantIds': updatedParticipantIds});
  }
}
