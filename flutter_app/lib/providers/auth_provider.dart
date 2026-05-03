import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  bool     _loading = false;
  String?  _error;

  AppUser? get user    => _user;
  bool     get loading => _loading;
  String?  get error   => _error;
  bool     get isLoggedIn => _user != null;

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final username = prefs.getString('username');
    final role = prefs.getString('role');
    final id   = prefs.getInt('userId');
    if (token != null && username != null && role != null && id != null) {
      _user = AppUser(id: id, username: username, role: role, token: token);
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password, String role) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final api  = ApiService();
      final body = <String, dynamic>{'username': username, 'role': role};
      if (role != 'guest') body['password'] = password;
      final data = await api.post('/auth/login', body);
      _user = AppUser.fromJson(data['user'] as Map<String, dynamic>, data['token'] as String);
      await _persist();
      _loading = false; notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message; _loading = false; notifyListeners();
      return false;
    } catch (_) {
      _error = 'No se pudo conectar al servidor';
      _loading = false; notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> _persist() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token',    _user!.token);
    await prefs.setString('username', _user!.username);
    await prefs.setString('role',     _user!.role);
    await prefs.setInt('userId',      _user!.id);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final api  = ApiService(_user!.token);
    final data = await api.get('/auth/users') as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  Future<void> deleteUser(int id) async {
    final api = ApiService(_user!.token);
    await api.delete('/auth/users/$id');
  }
}
