import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:reaxit/config.dart' as config;

/// A [BaseCacheManager] with customized configurations.
class ThaliaCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'thaliaCachedData';

  static final ThaliaCacheManager _instance = ThaliaCacheManager._();
  factory ThaliaCacheManager() => _instance;

  ThaliaCacheManager._()
      : super(Config(
          key,
          stalePeriod: config.cacheStalePeriod,
          maxNrOfCacheObjects: config.cacheMaxObjects,
        ));
}
