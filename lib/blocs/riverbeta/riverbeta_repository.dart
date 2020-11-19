import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';

class RiverbetaRepository {
  final RiverbetaProvider _riverbetaProvider = RiverbetaProvider();

  RiverbetaRepository();

  Future<List<RiverbetaModel>> getNearbyRivers(
      GeoFirePoint center, double distance) async {
    return _riverbetaProvider.getNearbyRivers(center, distance);
  }

  Future<RiverbetaModel> getRiverById(String riverId) async {
    return _riverbetaProvider.getRiverById(riverId);
  }

  Future<String> addRiver(RiverbetaModel newRiver) async {
    return _riverbetaProvider.addRiver(newRiver);
  }

  Future<String> updateRiverStat(
      String riverId, RiverAnnualStatModel newRiverStat) async {
    return _riverbetaProvider.updateRiverStat(riverId, newRiverStat);
  }

  Future<RiverAnnualStatModel> getRiverStat(String riverId) async {
    return _riverbetaProvider.getRiverStat(riverId);
  }

  void test(bool isError) {
    _riverbetaProvider.test(isError);
  }
}
