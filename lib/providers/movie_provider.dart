import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';

class MovieProvider with ChangeNotifier {
  final MovieService _movieService = MovieService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  List<Movie> get favoriteMovies => _favoriteMovies;

  bool get isSearching => _isSearching;
  bool get isLoading => _isLoading;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // =========================
  // FAVORITES
  // =========================

  Future<void> loadFavorites() async {
    final uid = _uid;
    if (uid == null) {
      _favoriteMovies = [];
      notifyListeners();
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('favorites')
          .get();

      _favoriteMovies =
          snapshot.docs.map((doc) => Movie.fromJson(doc.data())).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> toggleFavorite(Movie movie) async {
    final uid = _uid;
    if (uid == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(movie.id.toString());

    final isFav = isFavorite(movie);

    try {
      if (isFav) {
        _favoriteMovies.removeWhere((m) => m.id == movie.id);
        await docRef.delete();
      } else {
        _favoriteMovies.add(movie);
        await docRef.set(movie.toJson());
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  Future<void> removeFavorite(Movie movie) async {
    final uid = _uid;
    if (uid == null) return;

    try {
      _favoriteMovies.removeWhere((m) => m.id == movie.id);

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('favorites')
          .doc(movie.id.toString())
          .delete();

      notifyListeners();
    } catch (e) {
      debugPrint('Error removing favorite: $e');
    }
  }

  bool isFavorite(Movie movie) {
    return _favoriteMovies.any((m) => m.id == movie.id);
  }

  // =========================
  // MOVIES
  // =========================

  Future<void> fetchTrending() async {
    if (_isLoading || !_hasMoreTrending) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newItems =
          await _movieService.getTrendingMovies(page: _currentPage);

      if (newItems.isEmpty) {
        _hasMoreTrending = false;
      } else {
        _trendingMovies.addAll(newItems);
        _currentPage++;
      }
    } catch (e) {
      debugPrint('Error fetching trending: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchNewMovies() async {
    if (_isLoading || !_hasMoreNew) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newItems =
          await _movieService.getNowPlayingMovies(page: _newMoviesPage);

      if (newItems.isEmpty) {
        _hasMoreNew = false;
      } else {
        _newMovies.addAll(newItems);
        _newMoviesPage++;
      }
    } catch (e) {
      debugPrint('Error fetching new movies: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTopRatedMovies() async {
    if (_isLoading || !_hasMoreTopRated) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newItems =
          await _movieService.getTopRatedMovies(page: _topRatedPage);

      if (newItems.isEmpty) {
        _hasMoreTopRated = false;
      } else {
        _topRatedMovies.addAll(newItems);
        _topRatedPage++;
      }
    } catch (e) {
      debugPrint('Error fetching top rated: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // 🚀 Parallel loading (important fix)
  Future<void> fetchHomeData() async {
    await Future.wait([
      if (_trendingMovies.isEmpty) fetchTrending(),
      if (_newMovies.isEmpty) fetchNewMovies(),
      if (_topRatedMovies.isEmpty) fetchTopRatedMovies(),
    ]);
  }

  // =========================
  // SEARCH
  // =========================

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

    try {
      final results =
          await _movieService.searchMovies(query, page: _searchPage);

      _searchResults = results;

      if (results.isEmpty) {
        _hasMoreSearch = false;
      } else {
        _searchPage++;
      }
    } catch (e) {
      debugPrint('Error searching: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchNextSearchPage() async {
    if (_isLoading || !_hasMoreSearch || _currentQuery.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newItems = await _movieService.searchMovies(
        _currentQuery,
        page: _searchPage,
      );

      if (newItems.isEmpty) {
        _hasMoreSearch = false;
      } else {
        _searchResults.addAll(newItems);
        _searchPage++;
      }
    } catch (e) {
      debugPrint('Error fetching next search page: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearSearch() {
    _isSearching = false;
    _searchResults.clear();
    notifyListeners();
  }
}