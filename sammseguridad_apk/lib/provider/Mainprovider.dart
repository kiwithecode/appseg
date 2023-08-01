import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainProvider extends ChangeNotifier {
  static late SharedPreferences prefs;
  String _token = "";

  String get token => _token;

  bool get isAuth => _token.isNotEmpty;

  set token(String newToken) {
    _token = newToken;
    updateToken(_token);
    notifyListeners();
  }

  Future<void> updateToken(String token) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  Future<String> getPreferencesToken() async {
    try {
      prefs = await SharedPreferences.getInstance();
      _token = prefs.getString("token") ?? "";
      return _token;
    } catch (e) {
      return "";
    }
  }

  Future<void> logout() async {
    _token = "";
    await prefs.setString("token", "");
    notifyListeners();
  }

  Future<void> init() async {
    _token = await getPreferencesToken();
    notifyListeners();
  }
}
