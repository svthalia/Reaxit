import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:reaxit/config.dart' as config;

final cacheManager = _ThaliaCacheManager();

/// A [BaseCacheManager] with customized configurations.
class _ThaliaCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'thaliaCachedData';

  static final _ThaliaCacheManager _instance = _ThaliaCacheManager._();
  factory _ThaliaCacheManager() => _instance;

  _ThaliaCacheManager._()
      : super(Config(
          key,
          stalePeriod: config.cacheStalePeriod,
          maxNrOfCacheObjects: config.cacheMaxObjects,
        ));
}
