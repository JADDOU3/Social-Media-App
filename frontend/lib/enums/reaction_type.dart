import 'package:flutter/material.dart';
import '../utils/app_color.dart';

enum ReactionType {
  LIKE,
  LOVE,
  HAHA,
  ANGRY,
}

extension ReactionTypeExtension on ReactionType {
  IconData get icon {
    switch (this) {
      case ReactionType.LIKE:
        return Icons.thumb_up;
      case ReactionType.LOVE:
        return Icons.favorite;
      case ReactionType.HAHA:
        return Icons.sentiment_very_satisfied;
      case ReactionType.ANGRY:
        return Icons.sentiment_very_dissatisfied;
    }
  }

  Color get color {
    switch (this) {
      case ReactionType.LIKE:
        return AppColors.reactionLike;
      case ReactionType.LOVE:
        return AppColors.reactionLove;
      case ReactionType.HAHA:
        return AppColors.reactionHaha;
      case ReactionType.ANGRY:
        return AppColors.reactionAngry;
    }
  }

  String get label {
    switch (this) {
      case ReactionType.LIKE:
        return 'Like';
      case ReactionType.LOVE:
        return 'Love';
      case ReactionType.HAHA:
        return 'Haha';
      case ReactionType.ANGRY:
        return 'Angry';
    }
  }
}