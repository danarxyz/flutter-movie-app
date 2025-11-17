import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/media_item.dart';
import '../providers/favorites_provider.dart';

class FavoriteButton extends StatelessWidget {
  final MediaItem mediaItem;
  final String? addedMessage;
  final String? removedMessage;

  const FavoriteButton({
    super.key,
    required this.mediaItem,
    this.addedMessage,
    this.removedMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, favProvider, child) {
        final isFavorite = favProvider.isFavorite(
          mediaItem.id,
          mediaItem.mediaType,
        );

        return FilledButton.icon(
          onPressed: () {
            favProvider.toggleFavorite(mediaItem);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isFavorite
                      ? (removedMessage ?? 'Removed from favorites')
                      : (addedMessage ?? 'Added to favorites'),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_outline,
          ),
          label: Text(
            isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
          ),
        );
      },
    );
  }
}
