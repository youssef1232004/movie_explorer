import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/movie_provider.dart';
import '../providers/theme_provider.dart';
import '../models/movie.dart';
import 'login_screen.dart';
import 'movie_details.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _newMoviesController = ScrollController();
  final ScrollController _trendingController = ScrollController();
  final ScrollController _topRatedController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().fetchHomeData();
    });

    _newMoviesController.addListener(() {
      if (_newMoviesController.position.pixels >= _newMoviesController.position.maxScrollExtent - 200) {
        context.read<MovieProvider>().fetchNewMovies();
      }
    });
    
    _trendingController.addListener(() {
      if (_trendingController.position.pixels >= _trendingController.position.maxScrollExtent - 200) {
        context.read<MovieProvider>().fetchTrending();
      }
    });

    _topRatedController.addListener(() {
      if (_topRatedController.position.pixels >= _topRatedController.position.maxScrollExtent - 200) {
        context.read<MovieProvider>().fetchTopRatedMovies();
      }
    });
  }

  @override
  void dispose() {
    _newMoviesController.dispose();
    _trendingController.dispose();
    _topRatedController.dispose();
    super.dispose();
  }

  Widget _buildMovieSection(String title, List<Movie> movies, bool isLoading, ScrollController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 220,
          child: isLoading && movies.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => MovieDetailsScreen(movie: movie)
                        ));
                      },
                      child: Container(
                        width: 140,
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Card(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Hero(
                                  tag: 'movie_${movie.id}_$title',
                                  child: Image.network(
                                    movie.posterPath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.broken_image, size: 50),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0, left: 0, right: 0,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.transparent, Colors.black87],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      movie.title,
                                      style: const TextStyle(
                                        color: Colors.white, 
                                        fontWeight: FontWeight.bold, 
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = context.watch<MovieProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildMovieSection('New Movies', movieProvider.newMovies, movieProvider.isLoading, _newMoviesController),
            const SizedBox(height: 16),
            _buildMovieSection('Trending Now', movieProvider.trendingMovies, movieProvider.isLoading, _trendingController),
            const SizedBox(height: 16),
            _buildMovieSection('Top Rated', movieProvider.topRatedMovies, movieProvider.isLoading, _topRatedController),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}