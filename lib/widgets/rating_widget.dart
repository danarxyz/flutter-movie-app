import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final int voteCount;
  final double iconSize;
  final double fontSize;

  const RatingWidget({
    super.key,
    required this.rating,
    this.voteCount = 0,
    this.iconSize = 16,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          size: iconSize,
          color: Colors.amber[700],
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '/10',
          style: TextStyle(
            fontSize: fontSize - 2,
            color: Colors.grey[600],
          ),
        ),
        if (voteCount > 0) ...[
          const SizedBox(width: 8),
          Text(
            '(${_formatVoteCount(voteCount)})',
            style: TextStyle(
              fontSize: fontSize - 2,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  String _formatVoteCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
