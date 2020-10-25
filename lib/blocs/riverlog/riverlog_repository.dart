import 'package:yvrkayakers/blocs/riverlog/index.dart';

class RiverlogRepository {
  final RiverlogProvider _riverlogProvider = RiverlogProvider();

  RiverlogRepository();

  void test(bool isError) {
    _riverlogProvider.test(isError);
  }
}