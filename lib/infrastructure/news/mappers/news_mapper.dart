import 'dart:convert';

import 'package:sociale_vote/domain/common/value_objects/entity_id.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';

import '../models/news_dto.dart';

class NewsMapper {
  /// Converte un [NewsDto] in [NewsItem] di dominio.
  ///
  /// Importante:
  /// - gli ID dei provider news non sono affidabili come UUID Supabase
  /// - [countryCode]/[cityId] rappresentano il contesto feed
  /// - [contentLocation] rappresenta il luogo reale di cui parla la news
  ///
  /// Fix F9.4:
  /// - l'identità della news deve essere molto più stabile
  /// - normalizziamo la URL prima di generare l'UUID
  /// - evitiamo che query params / tracking / slash finali cambino id
  NewsItem toDomain(
    NewsDto dto, {
    String? countryCode,
    String? cityId,
    ContentLocation? contentLocation,
  }) {
    final effectiveContent = dto.content ?? dto.description ?? '';
    final effectiveAuthor = dto.sourceName ?? dto.sourceId ?? 'news';
    final breaking = _computeBreaking(dto);

    return NewsItem(
      id: EntityId(_buildStableUuid(dto)),
      title: dto.title,
      content: effectiveContent,
      summary: dto.description,
      imageUrl: dto.image,
      countryCode: countryCode,
      cityId: cityId,
      contentLocation: contentLocation,
      authorId: effectiveAuthor,
      publishedAt: dto.publishedAt,
      isBreaking: breaking,
    );
  }

  String _buildStableUuid(NewsDto dto) {
    final rawId = dto.id.trim();

    if (_isUuid(rawId)) {
      return rawId.toLowerCase();
    }

    final stableKey = _buildStableKey(dto);
    return _uuidFromString(stableKey);
  }

  String _buildStableKey(NewsDto dto) {
    final normalizedUrl = _normalizeStableUrl(dto.url);
    if (normalizedUrl != null && normalizedUrl.isNotEmpty) {
      return 'url:$normalizedUrl';
    }

    final normalizedRawId = _normalizeLooseToken(dto.id);
    if (normalizedRawId != null && normalizedRawId.isNotEmpty) {
      final source = _normalizeLooseToken(
            dto.sourceId ?? dto.sourceName ?? 'unknown',
          ) ??
          'unknown';
      return 'id:$source:$normalizedRawId';
    }

    final source = _normalizeLooseToken(
          dto.sourceId ?? dto.sourceName ?? 'unknown',
        ) ??
        'unknown';

    final normalizedTitle = _normalizeTitle(dto.title);
    final publishedAtUtc = dto.publishedAt.toUtc().toIso8601String();

    return 'title:$source:$normalizedTitle:$publishedAtUtc';
  }

  String? _normalizeStableUrl(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final parsed = Uri.tryParse(trimmed);
    if (parsed == null) {
      return trimmed.toLowerCase();
    }

    if (!parsed.hasScheme || parsed.host.trim().isEmpty) {
      return trimmed.toLowerCase();
    }

    final normalizedScheme = parsed.scheme.toLowerCase();
    final normalizedHost = parsed.host.toLowerCase();

    var normalizedPath = parsed.path.trim();
    if (normalizedPath.isEmpty) {
      normalizedPath = '/';
    } else {
      normalizedPath = normalizedPath.replaceFirst(RegExp(r'/+$'), '');
      if (normalizedPath.isEmpty) {
        normalizedPath = '/';
      }
    }

    final normalizedUri = Uri(
      scheme: normalizedScheme,
      host: normalizedHost,
      port: parsed.hasPort ? parsed.port : null,
      path: normalizedPath,
    );

    return normalizedUri.toString().toLowerCase();
  }

  String? _normalizeLooseToken(String? value) {
    if (value == null) {
      return null;
    }

    final trimmed = value.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return null;
    }

    return trimmed.replaceAll(RegExp(r'\s+'), ' ');
  }

  String _normalizeTitle(String value) {
    final trimmed = value.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return 'untitled';
    }

    return trimmed.replaceAll(RegExp(r'\s+'), ' ');
  }

  bool _isUuid(String value) {
    final regex = RegExp(
      r'^[0-9a-fA-F]{8}-'
      r'[0-9a-fA-F]{4}-'
      r'[0-9a-fA-F]{4}-'
      r'[0-9a-fA-F]{4}-'
      r'[0-9a-fA-F]{12}$',
    );
    return regex.hasMatch(value);
  }

  String _uuidFromString(String input) {
    final bytes = utf8.encode(input);

    final h1 = _fnv1a32(bytes, seed: 0x811C9DC5);
    final h2 = _fnv1a32(bytes, seed: 0x811C9DC5 ^ 0x9E3779B9);
    final h3 = _fnv1a32(bytes, seed: 0x811C9DC5 ^ 0x85EBCA6B);
    final h4 = _fnv1a32(bytes, seed: 0x811C9DC5 ^ 0xC2B2AE35);

    final data = <int>[
      ..._u32ToBytes(h1),
      ..._u32ToBytes(h2),
      ..._u32ToBytes(h3),
      ..._u32ToBytes(h4),
    ];

    data[6] = (data[6] & 0x0F) | 0x50;
    data[8] = (data[8] & 0x3F) | 0x80;

    final hex = data.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20, 32)}';
  }

  int _fnv1a32(
    List<int> bytes, {
    required int seed,
  }) {
    var hash = seed & 0xFFFFFFFF;

    for (final byte in bytes) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }

    return hash & 0xFFFFFFFF;
  }

  List<int> _u32ToBytes(int value) {
    return <int>[
      (value >> 24) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 8) & 0xFF,
      value & 0xFF,
    ];
  }

  bool _computeBreaking(NewsDto dto) {
    final now = DateTime.now().toUtc();
    final published = dto.publishedAt.toUtc();

    final age = now.difference(published);

    if (age.inHours <= 2) {
      return true;
    }

    final title = dto.title.toLowerCase();

    const keywords = [
      'breaking',
      'urgent',
      'alert',
      'ultim',
      'ultima ora',
    ];

    for (final k in keywords) {
      if (title.contains(k)) {
        return true;
      }
    }

    return false;
  }
}