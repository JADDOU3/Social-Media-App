import 'package:flutter/material.dart';
import '../utils/app_color.dart';
import 'image_viewer.dart';

class PostImageGrid extends StatelessWidget {
  final List<String> imageUrls;
  final bool isDark;

  const PostImageGrid({
    Key? key,
    required this.imageUrls,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    if (imageUrls.length == 1) {
      return GestureDetector(
        onTap: () => _openImageViewer(context, 0),
        child: Image.network(
          imageUrls[0],
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: isDark ? AppColors.darkShimmer : AppColors.lightShimmer,
              child: Icon(
                Icons.broken_image,
                size: 50,
                color: isDark
                    ? AppColors.darkTextLight
                    : AppColors.lightTextLight,
              ),
            );
          },
        ),
      );
    }
    return _buildImageWithOverlay(context);
  }

  Widget _buildImageWithOverlay(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _openImageViewer(context, 0),
              child: Image.network(
                imageUrls[0],
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 250,
                    color: isDark
                        ? AppColors.darkShimmer
                        : AppColors.lightShimmer,
                    child: Icon(
                      Icons.broken_image,
                      color: isDark
                          ? AppColors.darkTextLight
                          : AppColors.lightTextLight,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: GestureDetector(
              onTap: () => _openImageViewer(context, 1),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrls[1],
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 250,
                        color: isDark
                            ? AppColors.darkShimmer
                            : AppColors.lightShimmer,
                        child: Icon(
                          Icons.broken_image,
                          color: isDark
                              ? AppColors.darkTextLight
                              : AppColors.lightTextLight,
                        ),
                      );
                    },
                  ),
                  if (imageUrls.length > 2)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                      ),
                      child: Center(
                        child: Text(
                          '+${imageUrls.length - 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openImageViewer(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageViewerScreen(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
          isDark: isDark,
        ),
      ),
    );
  }
}

