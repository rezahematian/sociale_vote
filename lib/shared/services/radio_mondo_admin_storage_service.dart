import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:sociale_vote/core/supabase/supabase_client.dart';

import 'radio_mondo_web_audio_picker_stub.dart'
    if (dart.library.html) 'radio_mondo_web_audio_picker_html.dart'
    as web_audio_picker;

class RadioMondoPickedAudio {
  final String originalName;
  final String extension;
  final String contentType;
  final Uint8List bytes;

  const RadioMondoPickedAudio({
    required this.originalName,
    required this.extension,
    required this.contentType,
    required this.bytes,
  });

  int get sizeBytes => bytes.lengthInBytes;

  String get suggestedTitle {
    final dot = originalName.lastIndexOf('.');
    final stem = dot > 0 ? originalName.substring(0, dot) : originalName;
    return stem.replaceAll(RegExp(r'[_-]+'), ' ').trim();
  }
}

class RadioMondoUploadedAudio {
  final String path;
  final String publicUrl;

  const RadioMondoUploadedAudio({
    required this.path,
    required this.publicUrl,
  });
}

/// Admin-only helper for managed Radio Mondo audio in Supabase Storage.
///
/// The bucket is public because published Radio Mondo files are public media,
/// while INSERT/UPDATE/DELETE remain protected by Storage RLS for admins.
class RadioMondoAdminStorageService {
  RadioMondoAdminStorageService._();

  static final RadioMondoAdminStorageService instance =
      RadioMondoAdminStorageService._();

  static const String bucket = 'radio-mondo';
  static const int maxBytes = 200 * 1024 * 1024;
  static const List<String> allowedExtensions = <String>[
    'mp3',
    'm4a',
    'mp4',
    'aac',
    'ogg',
    'oga',
    'opus',
    'wav',
    'wave',
    'flac',
    'webm',
  ];

  static const Map<String, String> _contentTypes = <String, String>{
    'mp3': 'audio/mpeg',
    'm4a': 'audio/mp4',
    'mp4': 'audio/mp4',
    'aac': 'audio/aac',
    'ogg': 'audio/ogg',
    'oga': 'audio/ogg',
    'opus': 'audio/ogg',
    'wav': 'audio/wav',
    'wave': 'audio/wav',
    'flac': 'audio/flac',
    'webm': 'audio/webm',
  };

  Future<RadioMondoPickedAudio?> pickAudio() async {
    late String name;
    late Uint8List bytes;

    if (kIsWeb) {
      final browserFile = await web_audio_picker.pickBrowserAudio();
      if (browserFile == null) return null;

      name = browserFile.name.trim();
      bytes = browserFile.bytes;
    } else {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.single;
      name = file.name.trim();

      final fileBytes = file.bytes;
      if (fileBytes == null) {
        throw const FormatException(
          'Could not read the selected audio file.',
        );
      }

      bytes = fileBytes;
    }

    final extension = _extension(name);

    if (!allowedExtensions.contains(extension)) {
      throw const FormatException(
        'Unsupported Radio Mondo audio format.',
      );
    }

    if (bytes.isEmpty) {
      throw const FormatException(
        'Could not read the selected audio file.',
      );
    }

    if (bytes.lengthInBytes > maxBytes) {
      throw const FormatException(
        'Radio Mondo audio exceeds the 200 MB limit.',
      );
    }

    if (!_signatureMatches(extension, bytes)) {
      throw const FormatException(
        'The selected file does not match its audio extension.',
      );
    }

    return RadioMondoPickedAudio(
      originalName: name,
      extension: extension,
      contentType: _contentTypes[extension]!,
      bytes: bytes,
    );
  }

  Future<RadioMondoUploadedAudio> upload(RadioMondoPickedAudio audio) async {
    if (audio.bytes.isEmpty || audio.bytes.lengthInBytes > maxBytes) {
      throw ArgumentError('Invalid Radio Mondo audio payload.');
    }

    final path = 'tracks/${const Uuid().v4()}.${audio.extension}';
    final storage = AppSupabase.client.storage.from(bucket);
    await storage.uploadBinary(
      path,
      audio.bytes,
      fileOptions: FileOptions(
        upsert: false,
        cacheControl: '31536000',
        contentType: audio.contentType,
      ),
    );

    return RadioMondoUploadedAudio(
      path: path,
      publicUrl: storage.getPublicUrl(path),
    );
  }

  Future<void> removePath(String path) async {
    final normalized = path.trim();
    if (normalized.isEmpty) return;
    await AppSupabase.client.storage.from(bucket).remove(<String>[normalized]);
  }

  Future<bool> removeManagedUrlBestEffort(String? publicUrl) async {
    final path = managedPathFromPublicUrl(publicUrl);
    if (path == null) return false;
    try {
      await removePath(path);
      return true;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
            'Radio Mondo managed audio cleanup error: $error\n$stackTrace');
      }
      return false;
    }
  }

  String? managedPathFromPublicUrl(String? publicUrl) {
    final normalized = publicUrl?.trim();
    if (normalized == null || normalized.isEmpty) return null;
    final uri = Uri.tryParse(normalized);
    if (uri == null || uri.scheme != 'https') return null;

    final segments = uri.pathSegments;
    final publicIndex = segments.indexOf('public');
    if (publicIndex < 0 || publicIndex + 2 > segments.length) return null;
    if (segments[publicIndex + 1] != bucket) return null;

    final objectSegments = segments.sublist(publicIndex + 2);
    if (objectSegments.isEmpty) return null;
    final path = objectSegments.join('/');
    return path.startsWith('tracks/') ? path : null;
  }

  bool isManagedPublicUrl(String? publicUrl) =>
      managedPathFromPublicUrl(publicUrl) != null;

  static String _extension(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return '';
    return name.substring(dot + 1).toLowerCase();
  }

  static bool _signatureMatches(String extension, Uint8List bytes) {
    bool hasAscii(int offset, String value) {
      if (bytes.length < offset + value.length) return false;
      for (var i = 0; i < value.length; i++) {
        if (bytes[offset + i] != value.codeUnitAt(i)) return false;
      }
      return true;
    }

    switch (extension) {
      case 'ogg':
      case 'oga':
      case 'opus':
        return hasAscii(0, 'OggS');

      case 'm4a':
      case 'mp4':
        return bytes.length >= 12 && hasAscii(4, 'ftyp');

      case 'aac':
        return bytes.length >= 2 &&
            bytes[0] == 0xFF &&
            (bytes[1] & 0xF6) == 0xF0;

      case 'wav':
      case 'wave':
        return bytes.length >= 12 && hasAscii(0, 'RIFF') && hasAscii(8, 'WAVE');

      case 'flac':
        return hasAscii(0, 'fLaC');

      case 'webm':
        return bytes.length >= 4 &&
            bytes[0] == 0x1A &&
            bytes[1] == 0x45 &&
            bytes[2] == 0xDF &&
            bytes[3] == 0xA3;

      case 'mp3':
        if (bytes.length < 3) return false;
        final id3 = bytes[0] == 0x49 && bytes[1] == 0x44 && bytes[2] == 0x33;
        final frameSync =
            bytes.length >= 2 && bytes[0] == 0xFF && (bytes[1] & 0xE0) == 0xE0;
        return id3 || frameSync;

      default:
        return false;
    }
  }
}
