import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import '../services/local_storage.dart';

class MovieProvider with ChangeNotifier {
  final MovieService _movieService = MovieService();
  
  final List<Movie> _trendingMovies = [];
  List<Movie> _searchResults = [];
  List<Movie> _favoriteMovies = [];
  
  bool _isLoading = false;
  bool _isSearching = false;
  int _currentPage = 1;
  bool _hasMoreData = true;

  List<Movie> get movies => _isSearching ? _searchResults : _trendingMovies;
  List<Movie> get favoriteMovies => _favoriteMovies;
  bool get isLoading => _isLoading;

  MovieProvider() {
    _loadFavorites();
  }

  Future<void> fetchTrending() async {
    if (_isLoading || !_hasMoreData) return;
    
    _isLoading = true;
    // Delay notifyListeners slightly to prevent build errors during scroll
    Future.microtask(() => notifyListeners());

    final newMovies = await _movieService.getTrendingMovies(page: _currentPage);
    
    if (newMovies.isEmpty) {
      _hasMoreData = false;
    } else {
      _trendingMovies.addAll(newMovies);
      _currentPage++;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      _isSearching = false;
      _searchResults.clear();
      notifyListeners();
      return;
    }
    _isSearching = true;
    _isLoading = true;
    notifyListeners();

    _searchResults = await _movieService.searchMovies(query);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadFavorites() async {
    final favList = await LocalStorage.getFavorites();
    _favoriteMovies = favList.map((json) => Movie.fromJson(json)).toList();
    notifyListeners();
  }

  void toggleFavorite(Movie movie) {
    final isFav = isFavorite(movie);
    if (isFav) {
      _favoriteMovies.removeWhere((m) => m.id == movie.id);
    } else {
      _favoriteMovies.add(movie);
    }
    
    final favsJson = _favoriteMovies.map((m) => m.toJson()).toList();
    LocalStorage.saveFavorites(favsJson);
    notifyListeners();
  }

  bool isFavorite(Movie movie) {
    return _favoriteMovies.any((m) => m.id == movie.id);
  }
}