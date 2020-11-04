import 'package:yvrkayakers/blocs/trip/index.dart';

class TripRepository {
  final TripProvider _tripProvider = TripProvider();

  TripRepository();

  void test(bool isError) {
    _tripProvider.test(isError);
  }
}