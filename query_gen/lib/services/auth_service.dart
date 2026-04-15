import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _storage  = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';
  static const _emailKey = 'user_email';

  Future<void> saveToken(String token, String email) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _emailKey, value: email);
  }

  Future<String?> getToken() async => _storage.read(key: _tokenKey);
  Future<String?> getEmail() async => _storage.read(key: _emailKey);

  Future<void> logout() async => _storage.deleteAll();

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}