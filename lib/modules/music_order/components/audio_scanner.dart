import "dart:io";

import "package:flutter/foundation.dart";
import "package:audio_metadata_reader/audio_metadata_reader.dart";

class AudioScanner {
  /// 扫描音频文件
  static Future<List<AudioFile>> scanAudios() async {
    return compute(_scanAudiosInIsolate, null);
  }

  static Future<List<AudioFile>> _scanAudiosInIsolate(_) async {
    final List<AudioFile> results = [];
    final List<Directory> scanDirs = await _getScanDirectories();

    for (final dir in scanDirs) {
      await _scanDirectory(dir, results);
    }

    return results;
  }

  /// 获取需要扫描的目录
  static Future<List<Directory>> _getScanDirectories() async {
    // 直接返回外部存储根目录
    return [Directory("/storage/emulated/0")];
  }

  /// 递归扫描目录
  static Future<void> _scanDirectory(
    Directory directory,
    List<AudioFile> results
  ) async {
    try {
      final entities = directory.listSync(recursive: false);
      for (final entity in entities) {
        if (entity is Directory) {
          try {
            await _scanDirectory(entity, results);
          } catch (e) {
            print("无法访问目录: ${entity.path} - $e");
          }
        } else if (entity is File && _isAudioFile(entity.path)) {
          final metadata = await _readMetadata(entity);
          if (metadata != null) {
            results.add(metadata);
          }
        }
      }
    } catch (e) {
      print("扫描目录失败: ${directory.path} - $e");
    }
  }

  /// 判断是否为音频文件
  static bool _isAudioFile(String path) {
    const audioExtensions = [
      ".mp3", ".wav", ".flac", ".m4a", ".aac", ".ogg", ".opus"
    ];
    return audioExtensions.any((ext) => path.toLowerCase().endsWith(ext));
  }

  /// 读取音频元数据
  static Future<AudioFile?> _readMetadata(File file) async {
    try {
      final metadata = readMetadata(file, getImage: false);
      return AudioFile(
        path: file.path,
        title: metadata.title ?? file.path.split("/").last,
        artist: metadata.artist ?? "Unknown",
        duration: metadata.duration?.inMilliseconds ?? 0,
      );
    } catch (e) {
      print("读取元数据失败: ${file.path} - $e");
      return null;
    }
  }
}

class AudioFile {
  final String path;
  final String title;
  final String artist;
  final int duration;

  AudioFile({
    required this.path,
    required this.title,
    required this.artist,
    required this.duration,
  });

  @override
  String toString() {
    return "AudioFile{title: $title, artist: $artist, duration: $duration}";
  }
}