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
  bool get isSearching => _isSearching;

  List<Movie> get favoriteMovies => _favoriteMovies;
  bool get isLoading => _isLoading;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  MovieProvider() {
    loadFavorites();
  }

  // --- Favorites logic with Firestore ---

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

      _favoriteMovies = snapshot.docs
          .map((doc) => Movie.fromJson(doc.data()))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> toggleFavorite(Movie movie) async {
    final uid = _uid;
    if (uid == null) return;

    final isFav = isFavorite(movie);
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(movie.id.toString());

    try {
      if (isFav) {
        // Remove locally and from Firestore
        _favoriteMovies.removeWhere((m) => m.id == movie.id);
        await docRef.delete();
      } else {
        // Add locally and to Firestore
        _favoriteMovies.add(movie);
        await docRef.set(movie.toJson());
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      // Potential rollback of local state if needed, but keeping it simple
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

  // --- Movie fetching logic (unchanged core logic) ---

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
}