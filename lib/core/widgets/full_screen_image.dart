import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FullScreenImage extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;
  final bool isNetworkImage;

  const FullScreenImage({
    super.key,
    this.imageUrl,
    this.imageFile,
    this.isNetworkImage = true,
  }) : assert(imageUrl != null || imageFile != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Hero(
            tag: imageUrl ?? imageFile!.path,
            child:
                isNetworkImage
                    ? Image.network(
                      imageUrl!,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder:
                          (context, error, stackTrace) => const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                    )
                    : Image.file(
                      imageFile!,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    ),
          ),
        ),
      ),
    );
  }
}
