import 'package:flutter_cache_manager/flutter_cache_manager.dart' as cache;
import 'package:reaxit/config.dart';

/// A [BaseCacheManager] with customized configurations.
class ThaliaCacheManager extends cache.CacheManager
    with cache.ImageCacheManager {
  static const key = 'thaliaCachedData';

  static final ThaliaCacheManager _instance = ThaliaCacheManager._();
  factory ThaliaCacheManager() => _instance;

  ThaliaCacheManager._()
    : super(
        cache.Config(
          key,
          stalePeriod: Config.cacheStalePeriod,
          maxNrOfCacheObjects: Config.cacheMaxObjects,
        ),
      );
}
