import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:reaxit/config.dart' as config;

/// A [BaseCacheManager] with customized configurations.
class _ThaliaCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'thaliaCachedDate';

  static final _ThaliaCacheManager _instance = _ThaliaCacheManager._();
  factory _ThaliaCacheManager() => _instance;

  _ThaliaCacheManager._()
      : super(Config(
          key,
          stalePeriod: config.cacheStalePeriod,
          maxNrOfCacheObjects: config.cacheMaxObjects,
        ));
}

/// Wrapper for [CachedNetworkImage] with sensible defaults.
class CachedImage extends CachedNetworkImage {
  CachedImage({
    required String imageUrl,
    BoxFit fit = BoxFit.cover,
    Duration fadeOutDuration = const Duration(milliseconds: 200),
    Duration fadeInDuration = const Duration(milliseconds: 200),
    required String placeholder,
  }) : super(
          imageUrl: imageUrl,
          cacheManager: _ThaliaCacheManager(),
          cacheKey: Uri.parse(imageUrl).replace(query: '').toString(),
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
          cacheManager: _ThaliaCacheManager(),
          cacheKey: Uri.parse(imageUrl).replace(query: '').toString(),
        );
}
