import 'dart:io';
import 'package:flutter/material.dart';

class FullScreenImageViewer extends StatelessWidget {
  final String imagePath;
  final String tag;
  final bool isFile;

  const FullScreenImageViewer({
    super.key,
    required this.imagePath,
    required this.tag,
    this.isFile = true,
  });

  @override
  Widget build(BuildContext context) {
    print("============================");
    print(isFile);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: tag,
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child:
                    isFile
                        ? Image.network(
                          imagePath,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        )
                        : Image.asset(
                          imagePath,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
