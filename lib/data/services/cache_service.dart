import 'dart:convert';
import '../../core/values/app_value.dart';
import 'package:get/get.dart';
import 'storage_service.dart';

class CacheService extends GetxService {
  final StorageService _storage = Get.find<StorageService>();

  Future<CacheService> init() async {
    return this;
  }

  String scopedKey(String key, {String? scope}) {
    final safeScope = scope == null || scope.isEmpty ? 'global' : scope;
    return '${AppValues.keyCachePrefix}$safeScope.$key';
  }

  Future<void> saveMap(
    String key,
    Map<String, dynamic> value, {
    String? scope,
    int ttlSeconds = AppValues.shortCacheDuration,
  }) async {
    final dataKey = scopedKey(key, scope: scope);
    final expiresKey = '$dataKey.expires_at';

    await _storage.saveString(dataKey, jsonEncode(value));
    await _storage.saveInt(
      expiresKey,
      DateTime.now().millisecondsSinceEpoch + (ttlSeconds * 1000),
    );
  }

  Future<Map<String, dynamic>?> readMap(
    String key, {
    String? scope,
    bool allowStale = true,
  }) async {
    final dataKey = scopedKey(key, scope: scope);
    final expiresKey = '$dataKey.expires_at';
    final expiresAt = await _storage.getInt(expiresKey);

    if (!allowStale && expiresAt > 0) {
      final isExpired = DateTime.now().millisecondsSinceEpoch > expiresAt;
      if (isExpired) {
        return null;
      }
    }

    final raw = await _storage.getString(dataKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  Future<void> remove(String key, {String? scope}) async {
    final dataKey = scopedKey(key, scope: scope);
    await _storage.remove(dataKey);
    await _storage.remove('$dataKey.expires_at');
  }
}
