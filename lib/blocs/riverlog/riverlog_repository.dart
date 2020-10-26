import 'package:yvrkayakers/blocs/riverlog/index.dart';

class RiverlogRepository {
  final RiverlogProvider _riverlogProvider = RiverlogProvider();

  RiverlogRepository();

  Future<List<RiverlogModel>> getRiverLogByUser(String userId) async {
    return _riverlogProvider.getRiverLogByUser(userId);
  }

  Future<RiverlogModel> getRiverLogById(String riverLogId) async {
    return _riverlogProvider.getRiverLogById(riverLogId);
  }

  Future<String> addRiverLog(RiverlogModel newRiverLog) async {
    return _riverlogProvider.addRiverLog(newRiverLog);
  }

  void test(bool isError) {
    _riverlogProvider.test(isError);
  }
}
