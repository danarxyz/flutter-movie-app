import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/media_item.dart';
import '../config/api_config.dart';

class MediaCard extends StatelessWidget {
  final MediaItem item;
  final VoidCallback? onTap;

  const MediaCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster image
            Expanded(
              flex: 3,
              child: _buildPoster(),
            ),
            // Info section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  // Rating and year
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 12,
                        color: Colors.amber[700],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        item.formattedRating,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        item.releaseYear,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoster() {
    if (item.posterPath == null || item.posterPath!.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(
            Icons.movie,
            size: 48,
            color: Colors.grey,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: ApiConfig.getPosterUrl(item.posterPath),
      fit: BoxFit.cover,
      width: double.infinity,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(
            Icons.error,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
