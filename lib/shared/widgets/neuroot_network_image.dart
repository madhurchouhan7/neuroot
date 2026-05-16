import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A drop-in replacement for [Image.network] that shows a shimmer-style
/// placeholder while loading and a tinted ghost icon on error.
///
/// Usage:
/// ```dart
/// NeurootNetworkImage(
///   url: 'https://...',
///   width: 120,
///   height: 120,
///   fit: BoxFit.contain,
/// )
/// ```
class NeurootNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  /// Icon shown when the image fails to load. Defaults to [Icons.image_not_supported_rounded].
  final IconData errorIcon;
  /// Background color of the placeholder / error state.
  final Color placeholderColor;

  const NeurootNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorIcon = Icons.image_not_supported_rounded,
    this.placeholderColor = const Color(0xFFF5EFE3), // bloom-cream-dark
  });

  @override
  Widget build(BuildContext context) {
    Widget image = Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      // ── Loading placeholder ────────────────────────────────────────────
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child; // fully loaded
        return _Placeholder(
          width: width,
          height: height,
          color: placeholderColor,
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                  : null,
              color: AppColors.primaryContainer,
            ),
          ),
        );
      },
      // ── Error placeholder ──────────────────────────────────────────────
      errorBuilder: (context, error, stack) {
        return _Placeholder(
          width: width,
          height: height,
          color: placeholderColor,
          child: Icon(
            errorIcon,
            size: (width != null && height != null)
                ? ((width! + height!) / 4).clamp(16, 48)
                : 32,
            color: AppColors.textSecondary,
          ),
        );
      },
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }
}

// ── Internal placeholder container ────────────────────────────────────────────
class _Placeholder extends StatelessWidget {
  final double? width;
  final double? height;
  final Color color;
  final Widget child;

  const _Placeholder({
    required this.width,
    required this.height,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: color,
      alignment: Alignment.center,
      child: child,
    );
  }
}

/// Convenience extension so callers can do [SomeNetworkImage.networkSafe(url)].
extension NetworkImagePlaceholder on Image {
  static Widget safe(
    String url, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Color placeholderColor = const Color(0xFFF5EFE3),
  }) {
    return NeurootNetworkImage(
      url: url,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      placeholderColor: placeholderColor,
    );
  }
}
