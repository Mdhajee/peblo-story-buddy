import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ElevenLabsService {
  // Free-tier ElevenLabs config — replace with your key
  static const String _apiKey = 'YOUR_ELEVENLABS_API_KEY';
  static const String _voiceId = 'EXAVITQu4vr4xnSDxMaL'; // "Bella" — warm, friendly
  static const String _baseUrl = 'https://api.elevenlabs.io/v1';
  static const Duration _cacheExpiry = Duration(days: 7);

  /// Returns path to cached audio file, fetching from API if needed.
  /// Throws [ElevenLabsException] on unrecoverable failure.
  Future<String> getAudioPath(String text) async {
    final cacheKey = _cacheKey(text);
    final cacheFile = await _cacheFile(cacheKey);

    if (await _isCacheValid(cacheFile)) {
      return cacheFile.path;
    }

    final bytes = await _fetchFromApi(text);
    await cacheFile.writeAsBytes(bytes);
    await _writeCacheMeta(cacheKey);
    return cacheFile.path;
  }

  Future<Uint8List> _fetchFromApi(String text) async {
    final uri = Uri.parse('$_baseUrl/text-to-speech/$_voiceId');

    final response = await http
        .post(
          uri,
          headers: {
            'xi-api-key': _apiKey,
            'Content-Type': 'application/json',
            'Accept': 'audio/mpeg',
          },
          body: jsonEncode({
            'text': text,
            'model_id': 'eleven_multilingual_v2',
            'voice_settings': {
              'stability': 0.6,
              'similarity_boost': 0.8,
              'style': 0.3,
              'use_speaker_boost': true,
            },
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else if (response.statusCode == 401) {
      throw ElevenLabsException('Invalid API key');
    } else if (response.statusCode == 429) {
      throw ElevenLabsException('Rate limit reached');
    } else {
      throw ElevenLabsException('API error: ${response.statusCode}');
    }
  }

  String _cacheKey(String text) =>
      md5.convert(utf8.encode(text)).toString();

  Future<File> _cacheFile(String key) async {
    final dir = await getTemporaryDirectory();
    return File('${dir.path}/peblo_audio_$key.mp3');
  }

  Future<File> _cacheMetaFile(String key) async {
    final dir = await getTemporaryDirectory();
    return File('${dir.path}/peblo_audio_$key.meta');
  }

  Future<bool> _isCacheValid(File file) async {
    if (!await file.exists()) return false;
    final meta = await _cacheMetaFile(_cacheKey(''));
    if (!await meta.exists()) return false;

    try {
      final timestamp = int.parse(await meta.readAsString());
      final saved = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return DateTime.now().difference(saved) < _cacheExpiry;
    } catch (_) {
      return false;
    }
  }

  Future<void> _writeCacheMeta(String key) async {
    final meta = await _cacheMetaFile(key);
    await meta.writeAsString(
        DateTime.now().millisecondsSinceEpoch.toString());
  }

  Future<void> clearCache(String text) async {
    final key = _cacheKey(text);
    final file = await _cacheFile(key);
    final meta = await _cacheMetaFile(key);
    if (await file.exists()) await file.delete();
    if (await meta.exists()) await meta.delete();
  }
}

class ElevenLabsException implements Exception {
  final String message;
  ElevenLabsException(this.message);

  @override
  String toString() => 'ElevenLabsException: $message';
}
