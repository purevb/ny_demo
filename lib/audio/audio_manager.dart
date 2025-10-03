import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:ny/constants.dart';

class AudioCacheEntry {
  final AudioSource source;
  DateTime lastUsed;
  int playCount;

  AudioCacheEntry(this.source) : lastUsed = DateTime.now(), playCount = 0;

  void markUsed() {
    lastUsed = DateTime.now();
    playCount++;
  }
}

class NYAudioManager {
  static final NYAudioManager _instance = NYAudioManager._internal();
  factory NYAudioManager() => _instance;
  NYAudioManager._internal();

  final soloud = SoLoud.instance;
  final Map<String, AudioCacheEntry> _cache = {};
  bool _isInitialized = false;
  Timer? _cleanupTimer;

  static const Duration cacheTimeout = Duration(minutes: 5);
  static const Duration cleanupInterval = Duration(minutes: 2);

  Future<void> init() async {
    try {
      if (_isInitialized) {
        return;
      }

      await soloud.init();
      _isInitialized = true;
      _startCleanupTimer();
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(cleanupInterval, (_) {
      _performCleanup();
    });
  }

  void _performCleanup() {
    if (!_isInitialized) return;

    final keysToRemove = <String>[];

    if (_cache.length - keysToRemove.length > maxCacheSize) {
      final sortedEntries =
          _cache.entries.where((e) => !keysToRemove.contains(e.key)).toList()
            ..sort((a, b) => a.value.lastUsed.compareTo(b.value.lastUsed));

      final additionalRemovalCount =
          (_cache.length - keysToRemove.length) - maxCacheSize;
      for (int i = 0; i < additionalRemovalCount; i++) {
        keysToRemove.add(sortedEntries[i].key);
      }
    }

    for (final key in keysToRemove) {
      _removeCacheEntry(key);
    }

    if (keysToRemove.isNotEmpty) {
      debugPrint(
        'NYAudioManager: Cleaned up ${keysToRemove.length} cached audio files',
      );
    }
  }

  void _removeCacheEntry(String path) {
    final entry = _cache.remove(path);
    if (entry != null) {
      try {
        soloud.disposeSource(entry.source);
      } catch (e) {
        debugPrint('NYAudioManager: Error disposing source for $path - $e');
      }
    }
  }

  Future<void> playSound(String path, {double volume = 0.5}) async {
    if (!_isInitialized) {
      return;
    }

    try {
      AudioCacheEntry? entry = _cache[path];

      if (entry == null) {
        final src = await soloud.loadAsset(path);
        entry = AudioCacheEntry(src);
        _cache[path] = entry;

        if (_cache.length > maxCacheSize) {
          _performCleanup();
        }
      }

      entry.markUsed();
      await soloud.play(entry.source, volume: volume);
    } catch (e) {
      debugPrint('NYAudioManager: Failed to play sound $path - $e');
    }
  }

  Future<void> playSfx(String path, {double volume = 1.0}) async {
    await playSound(path, volume: volume);
  }

  Future<void> preloadAudio(String path, {bool priority = false}) async {
    if (!_isInitialized) {
      debugPrint('NYAudioManager: Not initialized, cannot preload audio');
      return;
    }

    try {
      if (!_cache.containsKey(path)) {
        final src = await soloud.loadAsset(path);
        final entry = AudioCacheEntry(src);
        _cache[path] = entry;

        if (priority) {
          entry.markUsed();
        }

        debugPrint('NYAudioManager: Preloaded audio $path');

        if (_cache.length > maxCacheSize) {
          _performCleanup();
        }
      }
    } catch (e) {
      debugPrint('NYAudioManager: Failed to preload audio $path - $e');
    }
  }

  Future<void> preloadMultiple(
    List<String> paths, {
    bool priority = false,
  }) async {
    for (final path in paths) {
      await preloadAudio(path, priority: priority);
    }
  }

  void removeFromCache(String path) {
    _removeCacheEntry(path);
    debugPrint('NYAudioManager: Removed $path from cache');
  }

  void clearCache() {
    try {
      for (final entry in _cache.values) {
        soloud.disposeSource(entry.source);
      }
      _cache.clear();
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<void> dispose() async {
    try {
      _cleanupTimer?.cancel();
      clearCache();
      if (_isInitialized) {
        soloud.deinit();
        _isInitialized = false;
      }
      debugPrint('NYAudioManager: Disposed');
    } catch (e) {
      debugPrint('NYAudioManager: Error during dispose - $e');
    }
  }

  bool get isInitialized => _isInitialized;
  int get cacheSize => _cache.length;
}
