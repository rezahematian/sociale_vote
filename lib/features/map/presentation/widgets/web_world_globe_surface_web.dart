import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:web/web.dart' as web;

import 'package:sociale_vote/features/map/application/civic_map_controller.dart';
import 'package:sociale_vote/app/localization/de_fallback.dart';
import 'package:sociale_vote/shared/widgets/social_vote_symbols.dart';

SocialVoteContentKind _contentKindForWebMapType(CivicMapItemType type) {
  return switch (type) {
    CivicMapItemType.poll => SocialVoteContentKind.vote,
    CivicMapItemType.post => SocialVoteContentKind.voce,
    CivicMapItemType.news => SocialVoteContentKind.news,
  };
}

class WebGlobeFocus {
  final double latitude;
  final double longitude;
  final double distance;

  const WebGlobeFocus({
    required this.latitude,
    required this.longitude,
    required this.distance,
  });
}

class WebWorldGlobeSurface extends StatefulWidget {
  final List<CivicMapItem> items;
  final bool homeProfile;
  final bool isAuthenticated;
  final bool autoRotateEnabled;
  final String visualStyle;
  final bool markerDataSettled;
  final ValueChanged<CivicMapItem> onMarkerTap;
  final void Function(double latitude, double longitude) onSurfaceTap;
  final ValueChanged<Offset>? onOrientationChanged;
  final void Function(double latitude, double longitude)? onDeepZoom;
  final ValueListenable<WebGlobeFocus?>? focusListenable;
  final double? initialFocusLatitude;
  final double? initialFocusLongitude;
  final double? initialFocusZoom;
  final VoidCallback onUnavailable;

  const WebWorldGlobeSurface({
    super.key,
    required this.items,
    required this.homeProfile,
    required this.isAuthenticated,
    required this.autoRotateEnabled,
    this.visualStyle = 'classic',
    this.markerDataSettled = true,
    required this.onMarkerTap,
    required this.onSurfaceTap,
    required this.onUnavailable,
    this.onOrientationChanged,
    this.onDeepZoom,
    this.focusListenable,
    this.initialFocusLatitude,
    this.initialFocusLongitude,
    this.initialFocusZoom,
  });

  @override
  State<WebWorldGlobeSurface> createState() => _WebWorldGlobeSurfaceState();
}

class _WebWorldGlobeSurfaceState extends State<WebWorldGlobeSurface> {
  static const String _earthTextureUrl =
      'assets/assets/globe/earth_day_nasa_bmng_august_4096.jpg';
  static const String _nightTextureUrl =
      'assets/assets/globe/earth_night_nasa_black_marble_2016_3600.jpg';

  web.HTMLElement? _element;

  JSFunction? _readyListener;
  JSFunction? _markerTapListener;
  JSFunction? _surfaceTapListener;
  JSFunction? _orientationListener;
  JSFunction? _deepZoomListener;
  JSFunction? _diagnosticsListener;
  JSFunction? _errorListener;

  Timer? _readyTimeout;

  bool _failed = false;
  bool _ready = false;
  String? _lastConfigJson;
  String? _lastAppearanceJson;
  String? _lastFocusJson;

  final Map<String, CivicMapItem> _markerLookup = <String, CivicMapItem>{};
  final Map<String, List<CivicMapItem>> _markerGroupLookup =
      <String, List<CivicMapItem>>{};

  @override
  void initState() {
    super.initState();
    widget.focusListenable?.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(covariant WebWorldGlobeSurface oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.focusListenable != widget.focusListenable) {
      oldWidget.focusListenable?.removeListener(_handleFocusChanged);
      widget.focusListenable?.addListener(_handleFocusChanged);
    }

    _applyConfigIfPossible();
    _applyAppearanceIfPossible();
    _applyFocusIfPossible();
  }

  @override
  void dispose() {
    widget.focusListenable?.removeListener(_handleFocusChanged);
    _readyTimeout?.cancel();
    _detachListeners();
    _element = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      final theme = Theme.of(context);

      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.public_off_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    Localizations.localeOf(context).languageCode == 'it'
                        ? '3D Web non disponibile'
                        : deOrEnglish(context,
                            english: '3D Web unavailable',
                            german: '3D im Web nicht verfügbar'),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Localizations.localeOf(context).languageCode == 'it'
                        ? 'Puoi continuare con la Civic Map 2D.'
                        : deOrEnglish(context,
                            english: 'You can continue with the 2D Civic Map.',
                            german:
                                'Du kannst mit der 2D Civic Map fortfahren.'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: widget.onUnavailable,
                    child: Text(
                      Localizations.localeOf(context).languageCode == 'it'
                          ? 'Apri mappa 2D'
                          : deOrEnglish(context,
                              english: 'Open 2D map',
                              german: '2D-Karte öffnen'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return HtmlElementView.fromTagName(
      tagName: 'social-vote-globe',
      isVisible: true,
      hitTestBehavior: PlatformViewHitTestBehavior.opaque,
      onElementCreated: _handleElementCreated,
    );
  }

  void _handleElementCreated(Object created) {
    final element = created as web.HTMLElement;
    _element = element;
    _failed = false;
    _ready = element.getAttribute('data-runtime-ready') == 'true';

    element.style
      ..display = 'block'
      ..width = '100%'
      ..height = '100%'
      ..overflow = 'visible'
      ..background = 'transparent';

    _readyListener = ((web.Event event) {
      _readyTimeout?.cancel();

      if (!mounted) {
        return;
      }

      setState(() {
        _ready = true;
        _failed = false;
      });
    }).toJS;

    _markerTapListener = ((web.Event event) {
      final detail = _detailAsMap(event);
      final markerId = detail?['markerId']?.toString();
      if (markerId == null) {
        return;
      }

      final item = _markerLookup[markerId];
      final group = _markerGroupLookup[markerId];
      if (item != null) {
        if (group != null && group.length > 1) {
          _showMarkerGroupPicker(group);
        } else {
          widget.onMarkerTap(item);
        }
      }
    }).toJS;

    _surfaceTapListener = ((web.Event event) {
      final detail = _detailAsMap(event);
      final latitude = _readDouble(detail?['latitude']);
      final longitude = _readDouble(detail?['longitude']);

      if (latitude == null || longitude == null) {
        return;
      }

      widget.onSurfaceTap(latitude, longitude);
    }).toJS;

    _orientationListener = ((web.Event event) {
      final callback = widget.onOrientationChanged;
      if (callback == null) {
        return;
      }

      final detail = _detailAsMap(event);
      final yaw = _readDouble(detail?['yaw']);
      final pitch = _readDouble(detail?['pitch']);

      if (yaw == null || pitch == null) {
        return;
      }

      callback(Offset(yaw, pitch));
    }).toJS;

    _deepZoomListener = ((web.Event event) {
      final callback = widget.onDeepZoom;
      if (callback == null) {
        return;
      }

      final detail = _detailAsMap(event);
      final latitude = _readDouble(detail?['latitude']);
      final longitude = _readDouble(detail?['longitude']);

      if (latitude == null || longitude == null) {
        return;
      }

      callback(latitude, longitude);
    }).toJS;

    _diagnosticsListener = ((web.Event event) {
      final detail = _detailAsMap(event);
      if (detail == null) {
        return;
      }

      // If diagnostics arrive, the custom element + WebGL renderer are alive.
      // Do not replace a working globe just because the texture took longer.
      _readyTimeout?.cancel();

      debugPrint(
        '[WEB-G3D DOM] '
        'build=${detail['build']} '
        'reason=${detail['reason']} '
        'host=${detail['hostWidth']}x${detail['hostHeight']} '
        'canvasCss=${detail['canvasCssWidth']}x${detail['canvasCssHeight']} '
        'canvasBuffer=${detail['canvasBufferWidth']}x${detail['canvasBufferHeight']} '
        'aspect=${detail['cameraAspect']} '
        'fov=${detail['cameraFov']} '
        'distance=${detail['cameraDistance']} '
        'pixelRatio=${detail['pixelRatio']} '
        'hostOverflow=${detail['hostOverflow']}',
      );
    }).toJS;

    _errorListener = ((web.Event event) {
      _readyTimeout?.cancel();

      if (!mounted || _failed) {
        return;
      }

      setState(() {
        _failed = true;
        _ready = false;
      });
    }).toJS;

    element.addEventListener(
      'socialvote-globe-ready',
      _readyListener,
    );
    element.addEventListener(
      'socialvote-marker-tap',
      _markerTapListener,
    );
    element.addEventListener(
      'socialvote-surface-tap',
      _surfaceTapListener,
    );
    element.addEventListener(
      'socialvote-globe-orientation',
      _orientationListener,
    );
    element.addEventListener(
      'socialvote-globe-deep-zoom',
      _deepZoomListener,
    );
    element.addEventListener(
      'socialvote-globe-diagnostics',
      _diagnosticsListener,
    );
    element.addEventListener(
      'socialvote-globe-error',
      _errorListener,
    );

    _applyConfigIfPossible(force: true);
    _applyAppearanceIfPossible(force: true);
    _applyFocusIfPossible(force: true);

    _readyTimeout?.cancel();
    if (_ready || element.getAttribute('data-runtime-ready') == 'true') {
      _ready = true;
      return;
    }
    _readyTimeout = Timer(const Duration(seconds: 30), () {
      if (!mounted || _ready) {
        return;
      }

      setState(() {
        _failed = true;
      });
    });
  }

  void _detachListeners() {
    final element = _element;
    if (element == null) {
      return;
    }

    if (_readyListener != null) {
      element.removeEventListener(
        'socialvote-globe-ready',
        _readyListener,
      );
    }
    if (_markerTapListener != null) {
      element.removeEventListener(
        'socialvote-marker-tap',
        _markerTapListener,
      );
    }
    if (_surfaceTapListener != null) {
      element.removeEventListener(
        'socialvote-surface-tap',
        _surfaceTapListener,
      );
    }
    if (_orientationListener != null) {
      element.removeEventListener(
        'socialvote-globe-orientation',
        _orientationListener,
      );
    }
    if (_deepZoomListener != null) {
      element.removeEventListener(
        'socialvote-globe-deep-zoom',
        _deepZoomListener,
      );
    }
    if (_diagnosticsListener != null) {
      element.removeEventListener(
        'socialvote-globe-diagnostics',
        _diagnosticsListener,
      );
    }
    if (_errorListener != null) {
      element.removeEventListener(
        'socialvote-globe-error',
        _errorListener,
      );
    }
  }

  Map<Object?, Object?>? _detailAsMap(web.Event event) {
    if (event is! web.CustomEvent) {
      return null;
    }

    final dartValue = event.detail.dartify();
    if (dartValue is Map<Object?, Object?>) {
      return dartValue;
    }

    if (dartValue is Map) {
      return Map<Object?, Object?>.from(dartValue);
    }

    return null;
  }

  double? _readDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '');
  }

  void _handleFocusChanged() {
    _applyFocusIfPossible();
  }

  void _applyConfigIfPossible({bool force = false}) {
    final element = _element;
    if (element == null) {
      return;
    }

    final configJson = jsonEncode(_buildConfig());

    if (!force && configJson == _lastConfigJson) {
      return;
    }

    _lastConfigJson = configJson;
    element.setAttribute('data-config', configJson);
  }

  void _applyAppearanceIfPossible({bool force = false}) {
    final element = _element;
    if (element == null) {
      return;
    }

    final appearanceJson = jsonEncode(_buildAppearance());
    if (!force && appearanceJson == _lastAppearanceJson) {
      return;
    }

    _lastAppearanceJson = appearanceJson;
    element.setAttribute('data-appearance', appearanceJson);
  }

  Map<String, Object?> _buildAppearance() {
    final textureUrl = switch (widget.visualStyle) {
      'realistic' => 'assets/assets/globe/earth_day_nasa_bmng_august_4096.jpg',
      'nightLights' => _nightTextureUrl,
      _ => _earthTextureUrl,
    };

    return <String, Object?>{
      'visualStyle': widget.visualStyle,
      'textureUrl': textureUrl,
      'nightTextureUrl': _nightTextureUrl,
    };
  }

  void _applyFocusIfPossible({bool force = false}) {
    final element = _element;
    final focus = widget.focusListenable?.value;

    if (element == null || focus == null) {
      return;
    }

    final focusJson = jsonEncode(<String, Object?>{
      'latitude': focus.latitude,
      'longitude': focus.longitude,
      'distance': focus.distance,
    });

    if (!force && focusJson == _lastFocusJson) {
      return;
    }

    _lastFocusJson = focusJson;
    element.setAttribute('data-focus', focusJson);
  }

  Map<String, Object?> _buildConfig() {
    final shouldPublishMarkers =
        widget.items.isNotEmpty || widget.markerDataSettled;
    final markers = shouldPublishMarkers ? _buildMarkers() : null;

    return <String, Object?>{
      'profile': widget.homeProfile ? 'home' : 'explore',
      'isAuthenticated': widget.isAuthenticated,
      'autoRotateEnabled': widget.autoRotateEnabled,
      if (markers != null) 'markers': markers,
      'markerDataSettled': widget.markerDataSettled,
      'maxTiltDegrees': widget.homeProfile ? 22.0 : 55.0,
      'initialFocusLatitude': widget.initialFocusLatitude,
      'initialFocusLongitude': widget.initialFocusLongitude,
      'initialFocusZoom': widget.initialFocusZoom,
    };
  }

  List<Map<String, Object?>> _buildMarkers() {
    _markerLookup.clear();
    _markerGroupLookup.clear();

    final clusterDegrees = widget.homeProfile ? 18.0 : 7.0;
    final markerLimit = widget.homeProfile ? 6 : 36;

    final validCandidates = widget.items.where(
      (item) =>
          item.latitude.isFinite &&
          item.longitude.isFinite &&
          item.latitude >= -90 &&
          item.latitude <= 90 &&
          item.longitude >= -180 &&
          item.longitude <= 180,
    );
    final limited = CivicMapMarkerSelectionRules.select(
      items: validCandidates,
      totalLimit: markerLimit,
      newsLimit: widget.homeProfile ? 1 : 4,
    );
    final grouped = <String, List<CivicMapItem>>{};

    for (final item in limited) {
      final latCell = (item.latitude / clusterDegrees).floor();
      final lngCell = (item.longitude / clusterDegrees).floor();
      // One geographic cell becomes one marker cluster regardless of content
      // type, preventing Vote/Voce/News overlap at the same city centre.
      final key = '$latCell|$lngCell';

      grouped.putIfAbsent(key, () => <CivicMapItem>[]).add(item);
    }

    final result = <Map<String, Object?>>[];
    var groupIndex = 0;

    for (final group in grouped.values) {
      if (group.isEmpty) {
        continue;
      }

      final representative = _preferredMarkerRepresentative(group);

      var latitudeTotal = 0.0;
      var longitudeTotal = 0.0;

      for (final item in group) {
        latitudeTotal += item.latitude;
        longitudeTotal += item.longitude;
      }

      final markerId =
          'web:${representative.type.name}:${representative.id}:$groupIndex';
      groupIndex += 1;

      _markerLookup[markerId] = representative;
      _markerGroupLookup[markerId] = List<CivicMapItem>.unmodifiable(group);

      result.add(<String, Object?>{
        'id': markerId,
        'latitude': latitudeTotal / group.length,
        'longitude': longitudeTotal / group.length,
        'color':
            group.length > 1 ? '#805AD5' : _markerColor(representative.type),
        'kind': _contentKindForWebMapType(representative.type).name,
        'count': group.length,
        'size': widget.homeProfile
            ? math.min(1.28, 1.0 + (group.length - 1) * 0.08)
            : math.min(1.20, 0.92 + (group.length - 1) * 0.06),
      });
    }

    return result;
  }

  CivicMapItem _preferredMarkerRepresentative(List<CivicMapItem> items) {
    final ordered = List<CivicMapItem>.from(items)
      ..sort((a, b) {
        final aNews = a.type == CivicMapItemType.news ? 1 : 0;
        final bNews = b.type == CivicMapItemType.news ? 1 : 0;
        if (aNews != bNews) {
          return aNews.compareTo(bNews);
        }
        return b.mapImportanceScore.compareTo(a.mapImportanceScore);
      });
    return ordered.first;
  }

  String _markerGroupTitle() {
    final languageCode = Localizations.localeOf(context).languageCode;
    if (languageCode == 'it') {
      return 'Contenuti in questo punto';
    }
    return deOrEnglish(
      context,
      english: 'Content at this location',
      german: 'Inhalte an diesem Ort',
    );
  }

  String _markerTypeLabel(CivicMapItemType type) {
    switch (type) {
      case CivicMapItemType.poll:
        return 'Vote';
      case CivicMapItemType.post:
        return 'Voce';
      case CivicMapItemType.news:
        return 'News';
    }
  }

  Future<void> _showMarkerGroupPicker(List<CivicMapItem> items) async {
    if (!mounted || items.isEmpty) {
      return;
    }

    final ordered = List<CivicMapItem>.from(items)
      ..sort((a, b) {
        final aNews = a.type == CivicMapItemType.news ? 1 : 0;
        final bNews = b.type == CivicMapItemType.news ? 1 : 0;
        if (aNews != bNews) {
          return aNews.compareTo(bNews);
        }
        return b.mapImportanceScore.compareTo(a.mapImportanceScore);
      });

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 460),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Text(
                    _markerGroupTitle(),
                    style:
                        Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                  ),
                ),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: ordered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (itemContext, index) {
                      final item = ordered[index];
                      final subtitle = item.subtitle?.trim();

                      return ListTile(
                        leading: Icon(
                          SocialVoteSymbols.contentIcon(
                            _contentKindForWebMapType(item.type),
                          ),
                          color: SocialVoteSymbols.contentColor(
                            _contentKindForWebMapType(item.type),
                          ),
                        ),
                        title: Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          subtitle == null || subtitle.isEmpty
                              ? _markerTypeLabel(item.type)
                              : '${_markerTypeLabel(item.type)} · $subtitle',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          widget.onMarkerTap(item);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _markerColor(CivicMapItemType type) {
    return SocialVoteSymbols.contentHex(_contentKindForWebMapType(type));
  }
}
