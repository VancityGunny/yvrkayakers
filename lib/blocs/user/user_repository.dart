import 'package:yvrkayakers/blocs/user/user_model.dart';
import 'package:yvrkayakers/blocs/user/user_provider.dart';

class UserRepository {
  final UserProvider _userProvider = UserProvider();

  UserRepository();

  // Return new userId
  Future<String> addUser(UserModel newUser) {
    return this._userProvider.addUser(newUser);
  }
}
