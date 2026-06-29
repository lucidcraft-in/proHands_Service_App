import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'full_screen_gallery_viewer.dart';

class GalleryGridScreen extends StatelessWidget {
  final List<String> images;
  final String title;

  const GalleryGridScreen({
    super.key,
    required this.images,
    this.title = 'Gallery',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          final imageUrl = images[index];
          final heroTag = 'gallery_grid_image_$index';

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => FullScreenGalleryViewer(
                        imagePaths: images,
                        initialIndex: index,
                        heroTagPrefix: 'gallery_grid_image_',
                      ),
                ),
              );
            },
            child: Hero(
              tag: heroTag,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Iconsax.image, color: Colors.grey),
                      ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
