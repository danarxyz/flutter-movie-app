import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/api_config.dart';

class BackdropWidget extends StatelessWidget {
  final String? backdropPath;
  final IconData placeholderIcon;
  final bool showGradient;

  const BackdropWidget({
    super.key,
    required this.backdropPath,
    this.placeholderIcon = Icons.image,
    this.showGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    if (backdropPath == null || backdropPath!.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: Center(
          child: Icon(
            placeholderIcon,
            size: 64,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: ApiConfig.getBackdropUrl(backdropPath),
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[300],
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.error),
          ),
        ),
        if (showGradient)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
