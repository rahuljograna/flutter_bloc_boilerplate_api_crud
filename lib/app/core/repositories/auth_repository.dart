import 'package:flutter_bloc_boilerplate/app/core/config/api.service.dart';
import 'package:flutter_bloc_boilerplate/app/core/config/api_endpoints.dart';
import 'package:flutter_bloc_boilerplate/app/services/shared_pref.dart';

class AuthRepository {
  static late String userToken;
  static late int userId;

  final HttpClient _httpClient = HttpClient();
  final SharedPreferencesManager _sharedPreferencesManager =
      SharedPreferencesManager();

  Future<void> init() async {
    try {
      final token = await _sharedPreferencesManager.getString('_authToken');
      final uid = await _sharedPreferencesManager.getInt('user_id');
      userId = uid!;
      userToken = '$token';
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<HttpResponse> loginWithEmailPassword(dynamic param) async {
    HttpResponse response = await _httpClient.postPublic(
        ApiEndPoints.loginWithEmailPassword, param);
    return response;
  }

  Future<HttpResponse> createAccount(dynamic param) async {
    HttpResponse response =
        await _httpClient.postPublic(ApiEndPoints.registerAccount, param);
    return response;
  }

  Future<void> saveToken(String token, int uid) async {
    _sharedPreferencesManager.putString('_authToken', token);
    _sharedPreferencesManager.putBool('isLoggedIn', true);
    _sharedPreferencesManager.putInt('user_id', uid);
  }

  Future<HttpResponse> logout() async {
    HttpResponse response =
        await _httpClient.postPrivate(ApiEndPoints.logout, {}, userToken);
    return response;
  }
}
