import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/user.dart';

class AuthService {
  final ApiClient _client = ApiClient();

  Future<User?> login(String username, String password) async {
    try {
      final response = await _client.dio.post(
        AppConstants.dummyAuthUrl,
        data: {'username': username, 'password': password},
      );
      return User.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }
}