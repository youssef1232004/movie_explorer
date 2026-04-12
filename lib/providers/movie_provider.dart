import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import '../services/local_storage.dart';

class MovieProvider with ChangeNotifier {
  final MovieService _movieService = MovieService();
  
  final List<Movie> _trendingMovies = [];
  final List<Movie> _newMovies = [];
  final List<Movie> _topRatedMovies = [];
  List<Movie> _searchResults = [];
  List<Movie> _favoriteMovies = [];
  
  bool _isLoading = false;
  bool _isSearching = false;
  int _currentPage = 1;
  int _newMoviesPage = 1;
  int _topRatedPage = 1;
  int _searchPage = 1;
  String _currentQuery = '';
  
  bool _hasMoreTrending = true;
  bool _hasMoreNew = true;
  bool _hasMoreTopRated = true;
  bool _hasMoreSearch = true;

  List<Movie> get trendingMovies => _trendingMovies;
  List<Movie> get newMovies => _newMovies;
  List<Movie> get topRatedMovies => _topRatedMovies;
  
  List<Movie> get searchResults => _searchResults;
  bool get isSearching => _isSearching;

  List<Movie> get favoriteMovies => _favoriteMovies;
  bool get isLoading => _isLoading;

  MovieProvider() {
    _loadFavorites();
  }

  Future<void> fetchTrending() async {
    if (_isLoading || !_hasMoreTrending) return;
    
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    final newItems = await _movieService.getTrendingMovies(page: _currentPage);
    
    if (newItems.isEmpty) {
      _hasMoreTrending = false;
    } else {
      _trendingMovies.addAll(newItems);
      _currentPage++;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchNewMovies() async {
    if (_isLoading || !_hasMoreNew) return;
    
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    final newItems = await _movieService.getNowPlayingMovies(page: _newMoviesPage);
    
    if (newItems.isEmpty) {
      _hasMoreNew = false;
    } else {
      _newMovies.addAll(newItems);
      _newMoviesPage++;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTopRatedMovies() async {
    if (_isLoading || !_hasMoreTopRated) return;
    
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    final newItems = await _movieService.getTopRatedMovies(page: _topRatedPage);
    
    if (newItems.isEmpty) {
      _hasMoreTopRated = false;
    } else {
      _topRatedMovies.addAll(newItems);
      _topRatedPage++;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchHomeData() async {
    // Fetch initial data for all 3 lists if empty
    if (_trendingMovies.isEmpty) await fetchTrending();
    if (_newMovies.isEmpty) await fetchNewMovies();
    if (_topRatedMovies.isEmpty) await fetchTopRatedMovies();
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      _isSearching = false;
      _searchResults.clear();
      _currentQuery = '';
      notifyListeners();
      return;
    }
    _isSearching = true;
    _currentQuery = query;
    _searchPage = 1;
    _hasMoreSearch = true;
    _isLoading = true;
    notifyListeners();

    _searchResults = await _movieService.searchMovies(query, page: _searchPage);
    if (_searchResults.isEmpty) {
      _hasMoreSearch = false;
    } else {
      _searchPage++;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchNextSearchPage() async {
    if (_isLoading || !_hasMoreSearch || _currentQuery.isEmpty) return;
    
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    final newItems = await _movieService.searchMovies(_currentQuery, page: _searchPage);
    
    if (newItems.isEmpty) {
      _hasMoreSearch = false;
    } else {
      _searchResults.addAll(newItems);
      _searchPage++;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  void clearSearch() {
    _isSearching = false;
    _searchResults.clear();
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

  void removeFavorite(Movie movie) {
    _favoriteMovies.removeWhere((m) => m.id == movie.id);
    final favsJson = _favoriteMovies.map((m) => m.toJson()).toList();
    LocalStorage.saveFavorites(favsJson);
    notifyListeners();
  }

  bool isFavorite(Movie movie) {
    return _favoriteMovies.any((m) => m.id == movie.id);
  }
}