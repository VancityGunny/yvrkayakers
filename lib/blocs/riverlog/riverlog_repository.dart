import 'package:yvrkayakers/blocs/riverlog/index.dart';
import 'package:yvrkayakers/blocs/riverbeta/index.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:yvrkayakers/blocs/user/user_model.dart';

class RiverlogRepository {
  final RiverlogProvider _riverlogProvider = RiverlogProvider();
  final RiverbetaRepository _riverbetaRepository = RiverbetaRepository();

  RiverlogRepository();

  Future<List<RiverlogModel>> getRiverLogByUser(String userId) async {
    return _riverlogProvider.getRiverLogByUser(userId);
  }

  Future<RiverlogModel> getRiverLogById(String riverLogId) async {
    return _riverlogProvider.getRiverLogById(riverLogId);
  }

  Future<String> addRiverLog(RiverlogModel newRiverLog) async {
    // check current river stat
    RiverAnnualStatModel newRiverStat =
        await _riverbetaRepository.getRiverStat(newRiverLog.river.id);

    var currentSequence = newRiverStat.entries
        .reduce((current, next) =>
            current.sequenceNumber > next.sequenceNumber ? current : next)
        .sequenceNumber;
    var result = _riverlogProvider.addRiverLog(newRiverLog);
    //also update RiverBeta stat

    newRiverStat.entries.add(new RiverStatUserEntry(newRiverLog.userId,
        newRiverLog.logDate, newRiverLog.id, (currentSequence + 1)));
    // check if user already exist in visitors
    if (newRiverStat.visitors
            .any((element) => element.id == newRiverLog.userId) ==
        false) {
      // add user to visitor list if this is missing
      var session = FlutterSession();
      var currentUser =
          UserShortModel.fromJson(await session.get("loggedInUser"));
      currentUser.id = await session.get("currentUserId");
      newRiverStat.visitors.add(currentUser);
    }
    _riverbetaRepository.updateRiverStat(newRiverLog.river.id, newRiverStat);
    return result;
  }

  void test(bool isError) {
    _riverlogProvider.test(isError);
  }
}
