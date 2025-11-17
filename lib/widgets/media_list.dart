import 'package:flutter/material.dart';
import '../models/media_item.dart';
import 'media_card.dart';

class MediaList extends StatelessWidget {
  final List<MediaItem> items;
  final bool isLoading;
  final String? errorMessage;
  final Function(MediaItem) onItemTap;
  final VoidCallback? onRetry;

  const MediaList({
    super.key,
    required this.items,
    this.isLoading = false,
    this.errorMessage,
    required this.onItemTap,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (isLoading && items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Error state
    if (errorMessage != null && items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      );
    }

    // Empty state
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No items found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    // Grid of items
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return MediaCard(
          item: item,
          onTap: () => onItemTap(item),
        );
      },
    );
  }
}
