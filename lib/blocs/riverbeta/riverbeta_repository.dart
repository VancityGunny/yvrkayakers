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
    return addRiver(newRiver);
  }

  void test(bool isError) {
    _riverbetaProvider.test(isError);
  }
}
