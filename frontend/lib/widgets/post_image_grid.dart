import 'package:flutter/material.dart';
import '../utils/app_color.dart';

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
    if (imageUrls.length == 2) {
      return _buildTwoImages();
    } else if (imageUrls.length == 3) {
      return _buildThreeImages();
    } else {
      return _buildGridImages();
    }
  }

  Widget _buildTwoImages() {
    return Row(
      children: imageUrls
          .map((url) => Expanded(
        child: Image.network(
          url,
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
      ))
          .toList(),
    );
  }

  Widget _buildThreeImages() {
    return Column(
      children: [
        Image.network(
          imageUrls[0],
          width: double.infinity,
          height: 250,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 250,
              color: isDark ? AppColors.darkShimmer : AppColors.lightShimmer,
              child: Icon(
                Icons.broken_image,
                color: isDark
                    ? AppColors.darkTextLight
                    : AppColors.lightTextLight,
              ),
            );
          },
        ),
        Row(
          children: [
            Expanded(
              child: Image.network(
                imageUrls[1],
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color:
                    isDark ? AppColors.darkShimmer : AppColors.lightShimmer,
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
            Expanded(
              child: Image.network(
                imageUrls[2],
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color:
                    isDark ? AppColors.darkShimmer : AppColors.lightShimmer,
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
          ],
        ),
      ],
    );
  }

  Widget _buildGridImages() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: imageUrls.length > 4 ? 4 : imageUrls.length,
      itemBuilder: (context, index) {
        if (index == 3 && imageUrls.length > 4) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrls[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color:
                    isDark ? AppColors.darkShimmer : AppColors.lightShimmer,
                    child: Icon(
                      Icons.broken_image,
                      color: isDark
                          ? AppColors.darkTextLight
                          : AppColors.lightTextLight,
                    ),
                  );
                },
              ),
              Container(
                color: Colors.black54,
                child: Center(
                  child: Text(
                    '+${imageUrls.length - 4}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return Image.network(
          imageUrls[index],
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: isDark ? AppColors.darkShimmer : AppColors.lightShimmer,
              child: Icon(
                Icons.broken_image,
                color: isDark
                    ? AppColors.darkTextLight
                    : AppColors.lightTextLight,
              ),
            );
          },
        );
      },
    );
  }
}