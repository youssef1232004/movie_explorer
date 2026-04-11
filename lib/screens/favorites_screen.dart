import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import 'movie_details.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<MovieProvider>().favoriteMovies;

    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: favorites.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.heart_broken, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No favorites yet!', style: TextStyle(fontSize: 20, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final movie = favorites[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(movie.posterPath, width: 60, height: 90, fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(Icons.movie, size: 50),
                      ),
                    ),
                    title: Text(movie.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('⭐ ${movie.rating.toStringAsFixed(1)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => context.read<MovieProvider>().toggleFavorite(movie),
                    ),
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => MovieDetailsScreen(movie: movie)
                    )),
                  ),
                );
              },
            ),
    );
  }
}