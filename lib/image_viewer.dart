import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:window_manager/window_manager.dart';
import 'package:image_app1/models/image_details.dart';
import 'package:image_app1/settings/settings_page.dart';
import 'package:image_app1/widgets/control_pill.dart';
import 'package:image_app1/widgets/info_panel.dart';
import 'package:image_app1/widgets/nav_arrow_button.dart';

class ImageViewer extends StatefulWidget {
  const ImageViewer({super.key});

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  List<String> images = [];
  int currentIndex = 0;

  bool isFullScreen = false;

  // each increase = 90deg clockwise
  int rotationCounter = 0;

  // controls fade out after a short idle (never while hovered)
  bool showControls = true;
  bool _hoveringControls = false;
  Timer? _hideTimer;

  // details panel
  bool showInfo = false;
  final Map<String, Future<ImageDetails>> _infoCache = {};

  // zoom
  static const double _minZoom = 1;
  static const double _maxZoom = 6;
  final _zoomController = TransformationController();
  Offset _doubleTapPos = Offset.zero;

  final focusNode = FocusNode();

  @override
  void dispose() {
    _hideTimer?.cancel();
    _zoomController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  // ── Controls auto-hide ──────────────────────────────────────
  void _wakeControls() {
    if (!showControls) setState(() => showControls = true);
    _restartHideTimer();
  }

  void _restartHideTimer() {
    _hideTimer?.cancel();
    if (_hoveringControls) return; // pointer is on a control: stay visible
    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && !_hoveringControls) setState(() => showControls = false);
    });
  }

  /// Wrap any control so the bar stays up while the pointer is on it.
  Widget _keepAlive(Widget child) {
    return MouseRegion(
      onEnter: (_) {
        _hoveringControls = true;
        _hideTimer?.cancel();
      },
      onHover: (_) {
        _hoveringControls = true;
        _hideTimer?.cancel();
      },
      onExit: (_) {
        _hoveringControls = false;
        _restartHideTimer();
      },
      child: child,
    );
  }

  // ==== Zoom ===
  //  
  void _resetZoom() => _zoomController.value = Matrix4.identity();

  /// Zoom by [factor] around [focal] (defaults to the window center).
  void _zoomBy(double factor, {Offset? focal}) {
    final current = _zoomController.value.getMaxScaleOnAxis();
    final target = (current * factor).clamp(_minZoom, _maxZoom);

    if (target <= _minZoom + 0.01) {
      _resetZoom(); // also clears leftover panning
      return;
    }

    final size = context.size!;
    final c = focal ?? Offset(size.width / 2, size.height / 2);
    final applied = target / current;

    final m = Matrix4.translationValues(c.dx, c.dy, 0) *
        Matrix4.diagonal3Values(applied, applied, 1) *
        Matrix4.translationValues(-c.dx, -c.dy, 0);

    _zoomController.value = m * _zoomController.value;
  }

  void zoomIn() => _zoomBy(1.25);
  void zoomOut() => _zoomBy(0.8);


  // ==== Details panel ==================================

  Future<ImageDetails> _infoFor(String filePath) =>
      _infoCache.putIfAbsent(filePath, () => loadImageDetails(filePath));

  void toggleInfo() => setState(() => showInfo = !showInfo);



  // === Files / navigation =====================================
   
  Future<void> pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result == null || result.files.single.path == null) return;

    final pickedFile = result.files.single.path!;
    final folder = path.dirname(pickedFile);

    const imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    final foundImages = Directory(folder)
        .listSync()
        .map((f) => f.path)
        .where((p) => imageExtensions.contains(path.extension(p).toLowerCase()))
        .toList()
      ..sort();

    final startIndex = foundImages.indexOf(pickedFile);

    _infoCache.clear(); // clear previous cache
    _resetZoom();
    setState(() {
      images = foundImages;
      currentIndex = startIndex < 0 ? 0 : startIndex;
      rotationCounter = 0;
    });
    _hoveringControls = false; // the file dialog may have swallowed onExit
    _wakeControls();
  }

  void goToNext() {
    if (currentIndex < images.length - 1) {
      _resetZoom();
      setState(() {
        rotationCounter = 0;
        currentIndex++;
      });
    }
  }

  void goToPrevious() {
    if (currentIndex > 0) {
      _resetZoom();
      setState(() {
        rotationCounter = 0;
        currentIndex--;
      });
    }
  }

  void rotateImage() {
    _resetZoom();
    setState(() => rotationCounter = (rotationCounter + 1) % 4);
  }

  Future<void> toggleFullScreen() async {
    if (isFullScreen) {
      await windowManager.setFullScreen(false);
      await windowManager.setTitleBarStyle(TitleBarStyle.normal);
    } else {
      await windowManager.setFullScreen(true);
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    }
    setState(() => isFullScreen = !isFullScreen);
  }

  Future<void> openSettings() async {
    _hoveringControls = false; // the new page may swallow onExit
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
    focusNode.requestFocus(); // restore keyboard shortcuts
    if (images.isNotEmpty) _wakeControls();
  }

  // ── Empty state ─────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Stack(
      children: [
        _emptyContent(),
        Positioned(
          top: 12,
          right: 12,
          child: IconButton(
            tooltip: 'Settings (Ctrl+,)',
            onPressed: openSettings,
            icon: const Icon(Icons.tune_rounded),
          ),
        ),
      ],
    );
  }

  Widget _emptyContent() {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primary.withValues(alpha: 0.12),
            ),
            child: Icon(Icons.photo_library_outlined,
                size: 48, color: cs.primary),
          ),
          const SizedBox(height: 24),
          Text('Open an image',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text(
            'Pick a photo to browse everything in its folder',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: pickImages,
            icon: const Icon(Icons.folder_open_rounded),
            label: const Text('Choose image'),
            style: FilledButton.styleFrom(
              shape: const StadiumBorder(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '← → browse   ·   F fullscreen   ·   Ctrl+R rotate   ·   + − 0 zoom   ·   I details',
            style: TextStyle(color: Colors.white30, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── Image view ──────────────────────────────────────────────
  Widget _buildImageView() {
    final current = images[currentIndex];

    return MouseRegion(
      onHover: (_) => _wakeControls(),
      child: Stack(
        children: [
          // Zoomable image, cross-fades between photos
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                key: ValueKey(current),
                onDoubleTapDown: (d) => _doubleTapPos = d.localPosition,
                onDoubleTap: () {
                  if (_zoomController.value.getMaxScaleOnAxis() > 1.01) {
                    _resetZoom();
                  } else {
                    _zoomBy(2.5, focal: _doubleTapPos); // toward the click
                  }
                },
                child: InteractiveViewer(
                  transformationController: _zoomController,
                  minScale: _minZoom,
                  maxScale: _maxZoom,
                  child: Center(
                    child: RotatedBox(
                      quarterTurns: rotationCounter,
                      child: Image.file(
                        File(current),
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Controls fade out when idle (but never while hovered)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !showControls,
              child: AnimatedOpacity(
                opacity: showControls ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                child: Stack(
                  children: [
                    Positioned(
                      left: 16,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _keepAlive(
                          NavArrowButton(
                            onPressed: goToPrevious,
                            icon: Icons.chevron_left_rounded,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _keepAlive(
                          NavArrowButton(
                            onPressed: goToNext,
                            icon: Icons.chevron_right_rounded,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 24,
                      left: 16,
                      right: 16,
                      child: Center(
                        // shrinks to fit on narrow windows
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _keepAlive(
                            ControlPill(
                              label: '${currentIndex + 1} / ${images.length}',
                              fileName: path.basename(current),
                              isFullScreen: isFullScreen,
                              isInfoOpen: showInfo,
                              onOpen: pickImages,
                              onZoomOut: zoomOut,
                              onZoomIn: zoomIn,
                              onRotate: rotateImage,
                              onFullscreen: toggleFullScreen,
                              onInfo: toggleInfo,
                              onSettings: openSettings,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Details panel: outside the fade layer, stays until closed
          if (showInfo)
            Positioned.fill(
              child: Center(
                child: InfoPanel(
                  future: _infoFor(current),
                  onClose: toggleInfo,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: focusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        if (event is! KeyDownEvent) return;
        final key = event.logicalKey;
        final ctrl = HardwareKeyboard.instance.isControlPressed;

        if (key == LogicalKeyboardKey.arrowLeft) {
          goToPrevious();
        } else if (key == LogicalKeyboardKey.arrowRight) {
          goToNext();
        } else if (key == LogicalKeyboardKey.keyF) {
          toggleFullScreen();
        } else if (ctrl && key == LogicalKeyboardKey.keyR) {
          rotateImage();
        } else if (ctrl && key == LogicalKeyboardKey.comma) {
          openSettings();
        } else if (key == LogicalKeyboardKey.keyI && images.isNotEmpty) {
          toggleInfo();
        } else if (key == LogicalKeyboardKey.escape && showInfo) {
          toggleInfo();
        } else if (key == LogicalKeyboardKey.equal ||
            key == LogicalKeyboardKey.numpadAdd) {
          zoomIn();
        } else if (key == LogicalKeyboardKey.minus ||
            key == LogicalKeyboardKey.numpadSubtract) {
          zoomOut();
        } else if (key == LogicalKeyboardKey.digit0 ||
            key == LogicalKeyboardKey.numpad0) {
          _resetZoom();
        }
        if (images.isNotEmpty) _wakeControls();
      },
      child: Scaffold(
        body: images.isEmpty ? _buildEmptyState() : _buildImageView(),
      ),
    );
  }
}
