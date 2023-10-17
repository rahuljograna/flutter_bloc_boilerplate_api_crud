import 'package:flutter_bloc_boilerplate/app/services/shared_pref.dart';

class SplashRepositry {
  final SharedPreferencesManager _sharedPreferencesManager =
      SharedPreferencesManager();

  Future<String?> userAuthToken() async {
    return await _sharedPreferencesManager.getString('_authToken');
  }
}
