import 'package:flutter/material.dart';
import 'package:image_app1/settings/app_settings.dart';
import 'package:image_app1/widgets/glass_surface.dart';

// Floating toolbar: open, counter + filename, zoom, rotate,
// fullscreen, details, settings.
class ControlPill extends StatelessWidget {
  final String label; // e.g. "3 / 24"
  final String fileName;
  final bool isFullScreen;
  final bool isInfoOpen;
  final VoidCallback onOpen;
  final VoidCallback onZoomOut;
  final VoidCallback onZoomIn;
  final VoidCallback onRotate;
  final VoidCallback onFullscreen;
  final VoidCallback onInfo;
  final VoidCallback onSettings;

  const ControlPill({
    super.key,
    required this.label,
    required this.fileName,
    required this.isFullScreen,
    required this.isInfoOpen,
    required this.onOpen,
    required this.onZoomOut,
    required this.onZoomIn,
    required this.onRotate,
    required this.onFullscreen,
    required this.onInfo,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appSettings,
      builder: (context, _) {
        final text = appSettings.pillTextSize;
        return GlassSurface(
          opacity: appSettings.pillOpacity,
          blur: appSettings.pillBlur,
          child: IconButtonTheme(
            data: IconButtonThemeData(
              style: IconButton.styleFrom(
                foregroundColor: Colors.white,
                iconSize: appSettings.pillIconSize,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Open image',
                  onPressed: onOpen,
                  icon: const Icon(Icons.folder_open_rounded),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: text,
                          fontWeight: FontWeight.w600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 220),
                        child: Text(
                          fileName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: text - 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Zoom out (-)',
                  onPressed: onZoomOut,
                  icon: const Icon(Icons.zoom_out_rounded),
                ),
                IconButton(
                  tooltip: 'Zoom in (+)',
                  onPressed: onZoomIn,
                  icon: const Icon(Icons.zoom_in_rounded),
                ),
                IconButton(
                  tooltip: 'Rotate (Ctrl+R)',
                  onPressed: onRotate,
                  icon: const Icon(Icons.rotate_right_rounded),
                ),
                IconButton(
                  tooltip:
                      isFullScreen ? 'Exit fullscreen (F)' : 'Fullscreen (F)',
                  onPressed: onFullscreen,
                  icon: Icon(isFullScreen
                      ? Icons.fullscreen_exit_rounded
                      : Icons.fullscreen_rounded),
                ),
                IconButton(
                  tooltip: 'Details (I)',
                  onPressed: onInfo,
                  icon: Icon(isInfoOpen
                      ? Icons.info_rounded
                      : Icons.info_outline_rounded),
                ),
                IconButton(
                  tooltip: 'Settings (Ctrl+,)',
                  onPressed: onSettings,
                  icon: const Icon(Icons.tune_rounded),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
