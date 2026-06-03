import 'package:flutter/material.dart';

/// A reusable avatar widget that handles loading user profile photos.
/// Supports network images (such as Google profile URLs), local asset paths,
/// and falls back to a default asset placeholder when no image is specified.
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
    ImageProvider imageProvider;
    final hasImage = photoUrl != null && photoUrl!.isNotEmpty;

    if (hasImage) {
      if (photoUrl!.startsWith('http://') || photoUrl!.startsWith('https://')) {
        imageProvider = NetworkImage(photoUrl!);
      } else {
        imageProvider = AssetImage(photoUrl!);
      }
    } else {
      imageProvider = const AssetImage('assets/images/3c67757cef723535a7484a6c7bfbfc43.jpg');
    }

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: imageProvider,
    );

    if (borderWidth > 0 && borderColor != null) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor!, width: borderWidth),
        ),
        child: avatar,
      );
    }

    return avatar;
  }
}
