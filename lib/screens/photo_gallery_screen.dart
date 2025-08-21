import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../constants/app_constants.dart';
import '../models/gallery_model.dart';
 import '../utils/app_utils.dart';
import '../widgets/custom_app_bar.dart';

class PhotoGalleryScreen extends StatefulWidget {
  const PhotoGalleryScreen({super.key});

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
   List<GalleryModel> _galleryImages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGalleryImages();
  }

  Future<void> _loadGalleryImages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final images = await getGalleryImages();
      setState(() {
        _galleryImages = images;
        _isLoading = false;
      });
      print("Gallery images loaded successfully: ${_galleryImages.length} images $images");
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error loading gallery images: $e");
      AppUtils.showToast('Error loading gallery images: $e');
    }
  }

  void _openGalleryView(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GalleryViewPage(
          galleryImages: _galleryImages,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Photo Gallery',
      ),
      body: _isLoading
          ? Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: AppConstants.primaryColor,
                size: 50,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadGalleryImages,
              color: AppConstants.primaryColor,
              child: _galleryImages.isEmpty
                  ? const Center(
                      child: Text(
                        'No gallery images available',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: _galleryImages.length,
                      itemBuilder: (context, index) {
                        final image = _galleryImages[index];
                        return _buildGalleryItem(image, index);
                      },
                    ),
            ),
    );
  }

  Widget _buildGalleryItem(GalleryModel image, int index) {
    return GestureDetector(
      onTap: () => _openGalleryView(index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(red: 128, green: 128, blue: 128, alpha: 51), // 0.2 alpha
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              CachedNetworkImage(
                imageUrl: image.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: AppConstants.primaryColor,
                      size: 30,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              ),
              
              // Title overlay at bottom
              if (image.title != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 179), // 0.7 alpha
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Text(
                      image.title!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class GalleryViewPage extends StatefulWidget {
  final List<GalleryModel> galleryImages;
  final int initialIndex;

  const GalleryViewPage({
    super.key,
    required this.galleryImages,
    required this.initialIndex,
  });

  @override
  State<GalleryViewPage> createState() => _GalleryViewPageState();
}

class _GalleryViewPageState extends State<GalleryViewPage> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.galleryImages[_currentIndex].title ?? 'Photo Gallery',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          // Photo View Gallery
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(
                  widget.galleryImages[index].imageUrl,
                ),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 2,
                heroAttributes: PhotoViewHeroAttributes(
                  tag: 'gallery_${widget.galleryImages[index].id}',
                ),
              );
            },
            itemCount: widget.galleryImages.length,
            loadingBuilder: (context, event) => Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: AppConstants.primaryColor,
                size: 50,
              ),
            ),
            pageController: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          
          // Description overlay at bottom
          if (widget.galleryImages[_currentIndex].description != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 179), // 0.7 alpha
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  widget.galleryImages[_currentIndex].description!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}