import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:reaxit/utilities/cache_manager.dart' as cache;
import 'package:reaxit/config.dart' as config;

/// Wrapper for [CachedNetworkImage] with sensible defaults.
class CachedImage extends CachedNetworkImage {
  CachedImage({
    required String imageUrl,
    BoxFit fit = BoxFit.cover,
    Duration fadeOutDuration = const Duration(milliseconds: 200),
    Duration fadeInDuration = const Duration(milliseconds: 200),
    required String placeholder,
  }) : super(
          key: ValueKey(imageUrl),
          imageUrl: imageUrl,
          cacheManager: cache.cacheManager,

          /// If the image is from thalia.nu, remove the query part of the url
          /// from its key in the cache. Private images from concrexit have a
          /// signature in the url that expires every 3 hours. Removing this
          /// signature makes sure that the same cache object can be used
          /// regardless of the signature. This assumes that the qurey part is
          /// only used for authentication, not to identify the image, so the
          /// remaining path is a unique key.
          /// If the url is not from thalia.nu, use the full url as the key.
          cacheKey: (Uri.parse(imageUrl).host == config.apiHost ||
                  Uri.parse(imageUrl).host == config.apiHostCDN)
              ? Uri.parse(imageUrl).replace(query: '').toString()
              : imageUrl,
          fit: fit,
          fadeOutDuration: fadeOutDuration,
          fadeInDuration: fadeInDuration,
          placeholder: (_, __) => Image.asset(placeholder, fit: fit),
        );
}

/// Wrapper for [CachedNetworkImageProvider] with sensible defaults.
class CachedImageProvider extends CachedNetworkImageProvider {
  CachedImageProvider(String imageUrl)
      : super(
          imageUrl,
          cacheManager: cache.cacheManager,
          cacheKey: Uri.parse(imageUrl).replace(query: '').toString(),
        );
}
