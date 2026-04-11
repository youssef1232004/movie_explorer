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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.heart_broken, size: 100, color: Colors.redAccent.withOpacity(0.5)),
                  const SizedBox(height: 24),
                  const Text('No favorites yet!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text('Explore and add your favorite movies here', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final movie = favorites[index];
                return Card(
                  elevation: 3,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Hero(
                      tag: 'movie_${movie.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(movie.posterPath, width: 70, height: 100, fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(width: 70, height: 100, color: Colors.grey.shade300, child: const Icon(Icons.movie, size: 40)),
                        ),
                      ),
                    ),
                    title: Text(movie.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(movie.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 28),
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