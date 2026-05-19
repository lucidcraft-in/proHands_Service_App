import 'package:flutter/material.dart';

class FullScreenGalleryViewer extends StatefulWidget {
  final List<String> imagePaths;
  final List<String?>? notes;
  final int initialIndex;
  final String heroTagPrefix;

  const FullScreenGalleryViewer({
    super.key,
    required this.imagePaths,
    required this.initialIndex,
    this.notes,
    this.heroTagPrefix = 'gallery_image_',
  });

  @override
  State<FullScreenGalleryViewer> createState() =>
      _FullScreenGalleryViewerState();
}

class _FullScreenGalleryViewerState extends State<FullScreenGalleryViewer> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imagePaths.length,
            itemBuilder: (context, index) {
              final imagePath = widget.imagePaths[index];
              final tag = '${widget.heroTagPrefix}$index';

              return Center(
                child: Hero(
                  tag: tag,
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.network(
                      imagePath,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, color: Colors.white),
                    ),
                  ),
                ),
              );
            },
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
          // Note Indicator
          if (widget.notes != null)
            Positioned(
              bottom: widget.imagePaths.length > 1
                  ? MediaQuery.of(context).padding.bottom + 70
                  : MediaQuery.of(context).padding.bottom + 20,
              left: 20,
              right: 20,
              child: Center(
                child: AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    int currentPage = widget.initialIndex;
                    if (_pageController.hasClients) {
                      currentPage = _pageController.page?.round() ?? widget.initialIndex;
                    }
                    if (currentPage < widget.notes!.length) {
                      final note = widget.notes![currentPage];
                      if (note != null && note.isNotEmpty) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.15)),
                          ),
                          child: Text(
                            note,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          // Page Indicator
          if (widget.imagePaths.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      int currentPage = widget.initialIndex;
                      if (_pageController.hasClients) {
                        currentPage = _pageController.page?.round() ?? widget.initialIndex;
                      }
                      return Text(
                        '${currentPage + 1} / ${widget.imagePaths.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
