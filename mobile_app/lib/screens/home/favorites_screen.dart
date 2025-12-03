import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/property.dart';
import '../property/property_details_screen.dart';
import '../../widgets/login_required_widget.dart';
import '../../utils/helpers.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoriteProvider>(context, listen: false).fetchFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Si non authentifié, afficher un message
    if (authProvider.user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FE),
        body: LoginRequiredWidget(
          title: 'Favorites',
          message: 'Sign in to save your favorite properties and access them anytime.',
          icon: Icons.favorite,
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
          child: Column(
            children: [
              // Modern AppBar with Gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.all(20.0),
                child: const Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'My Favorites',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Consumer<FavoriteProvider>(
        builder: (context, favoriteProvider, child) {
          if (favoriteProvider.isLoading && favoriteProvider.favorites.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (favoriteProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    favoriteProvider.error!,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => favoriteProvider.fetchFavorites(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (favoriteProvider.favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No Favorites Yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start adding properties to your favorites',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 16),
            itemCount: favoriteProvider.favorites.length,
            itemBuilder: (context, index) {
              final favorite = favoriteProvider.favorites[index];
              final property = favorite.property;
              return FavoritePropertyCard(
                property: property,
                onRemove: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await favoriteProvider.removeFavorite(property.id);
                  if (mounted) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Removed from favorites'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            },
          );  
        },
      ),
              ),
            ],
          ),
      ),
    );
  }
}

class FavoritePropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onRemove;

  const FavoritePropertyCard({
    super.key,
    required this.property,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PropertyDetailsScreen(property: property),
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (property.images.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
                child: CachedNetworkImage(
                  imageUrl: property.images.first,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            property.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: onRemove,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Helpers.formatCurrency(property.price),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${property.location.city}, ${property.location.country}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildFeature(Icons.bed, property.bedrooms.toString()),
                        const SizedBox(width: 12),
                        _buildFeature(Icons.bathtub, property.bathrooms.toString()),
                        const SizedBox(width: 12),
                        _buildFeature(Icons.square_foot, '${property.area.toInt()}m²'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
