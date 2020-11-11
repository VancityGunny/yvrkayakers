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

  Future<String> addTripParticipant(
      String tripId, TripParticipant newTripParticipant) async {
    return _tripProvider.addTripParticipant(tripId, newTripParticipant);
  }

  Future<String> removeTripParticipant(
      String tripId, String removeUserId) async {
    return _tripProvider.removeTripParticipant(tripId, removeUserId);
  }
}
