import 'package:yvrkayakers/blocs/trip/index.dart';

class TripRepository {
  final TripProvider _tripProvider = TripProvider();

  TripRepository();

  void test(bool isError) {
    _tripProvider.test(isError);
  }

  Future<String> addTrip(TripModel newTrip) async {
    return _tripProvider.addTrip(newTrip);
  }

  Future<String> addTripComment(
      String tripId, TripCommentModel newComment) async {
    return _tripProvider.addTripComment(tripId, newComment);
  }

  Future<String> addTripParticipant(
      String tripId, TripParticipantModel newTripParticipant) async {
    return _tripProvider.addTripParticipant(tripId, newTripParticipant);
  }

  Future<void> removeTripParticipant(String tripId, String removeUserId) async {
    _tripProvider.removeTripParticipant(tripId, removeUserId);
  }
}
