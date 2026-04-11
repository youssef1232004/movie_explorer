import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/movie.dart';

class MovieService {
  final ApiClient _client = ApiClient();

  Future<List<Movie>> getTrendingMovies({int page = 1}) async {
    try {
      final response = await _client.dio.get(
        '${AppConstants.tmdbBaseUrl}/trending/movie/day',
        queryParameters: {'api_key': AppConstants.tmdbApiKey, 'page': page},
      );
      List data = response.data['results'];
      return data.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    try {
      final response = await _client.dio.get(
        '${AppConstants.tmdbBaseUrl}/search/movie',
        queryParameters: {'api_key': AppConstants.tmdbApiKey, 'query': query},
      );
      List data = response.data['results'];
      return data.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}