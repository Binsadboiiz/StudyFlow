import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A robust avatar widget that handles loading user profile photos.
/// Uses ClipRRect instead of CircleAvatar to support proper error/loading indicators,
/// handle CORS limitations on Flutter Web, and prevent visual image overflow.
class UserAvatar extends StatelessWidget {
  /// The photo URL or asset path of the user's avatar.
  final String? photoUrl;

  /// The radius of the avatar.
  final double radius;

  /// An optional border color.
  final Color? borderColor;

  /// The width of the optional border.
  final double borderWidth;

  const UserAvatar({
    super.key,
    this.photoUrl,
    required this.radius,
    this.borderColor,
    this.borderWidth = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final hasImage = photoUrl != null && photoUrl!.isNotEmpty;
    
    // Calculate optimal cache size based on screen pixel density to optimize RAM usage
    final devicePixelRatio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0;
    final cacheSize = (size * devicePixelRatio).round();

    debugPrint('UserAvatar: building with photoUrl = "$photoUrl"');

    Widget imageWidget;
    if (hasImage) {
      if (photoUrl!.startsWith('http://') || photoUrl!.startsWith('https://')) {
        // Bypass CORS on Flutter Web using images.weserv.nl proxy
        final resolvedUrl = kIsWeb
            ? 'https://images.weserv.nl/?url=${Uri.encodeComponent(photoUrl!)}'
            : photoUrl!;
        
        debugPrint('UserAvatar: Resolved network url = "$resolvedUrl"');

        imageWidget = Image.network(
          resolvedUrl,
          width: size,
          height: size,
          cacheWidth: cacheSize,
          cacheHeight: cacheSize,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('UserAvatar: Error loading network image "$photoUrl": $error');
            return _buildFallbackImage(context, size, cacheSize);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: SizedBox(
                width: size * 0.4,
                height: size * 0.4,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
            );
          },
        );
      } else {
        imageWidget = Image.asset(
          photoUrl!,
          width: size,
          height: size,
          cacheWidth: cacheSize,
          cacheHeight: cacheSize,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('UserAvatar: Error loading asset image "$photoUrl": $error');
            return _buildFallbackImage(context, size, cacheSize);
          },
        );
      }
    } else {
      imageWidget = _buildFallbackImage(context, size, cacheSize);
    }

    final avatar = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: size,
        height: size,
        color: Colors.grey.shade200,
        child: imageWidget,
      ),
    );

    if (borderWidth > 0 && borderColor != null) {
      return Container(
        width: size + (borderWidth * 2),
        height: size + (borderWidth * 2),
        padding: EdgeInsets.all(borderWidth),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor!, width: borderWidth),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: avatar,
        ),
      );
    }

    return avatar;
  }

  Widget _buildFallbackImage(BuildContext context, double size, int cacheSize) {
    return Image.asset(
      'assets/images/3c67757cef723535a7484a6c7bfbfc43.jpg',
      width: size,
      height: size,
      cacheWidth: cacheSize,
      cacheHeight: cacheSize,
      fit: BoxFit.cover,
    );
  }
}
