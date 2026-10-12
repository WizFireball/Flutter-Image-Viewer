import 'package:flutter/material.dart';
import 'package:image_app1/models/image_details.dart';
import 'package:image_app1/settings/app_settings.dart';
import 'package:image_app1/widgets/glass_surface.dart';

// Centered details card
// Its opacity and frosted effect are controlled
// by their own settings in setting page
class InfoPanel extends StatelessWidget {
  final Future<ImageDetails> future;
  final VoidCallback onClose;

  const InfoPanel({super.key, required this.future, required this.onClose});

  String _date(DateTime t) =>
      '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}  '
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      // this going to be pain in ass to read after some months later
      // if you open this in future just chatGpt copy paste above lines to
      // understand them

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appSettings,
      builder: (context, _) => GlassSurface(
        opacity: appSettings.infoOpacity,
        blur: appSettings.infoBlur,
        radius: 20,
        padding: const EdgeInsets.fromLTRB(24, 12, 12, 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 320, maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close (Esc)',
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ],
              ),
              FutureBuilder<ImageDetails>(
                future: future,
                builder: (context, snap) {
                  if (snap.hasError) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Could not read this image',
                          style: TextStyle(color: Colors.white70)),
                    );
                  }
                  if (!snap.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  final d = snap.data!;
                  return Column(
                    children: [
                      _row('Name', d.name),
                      _row('Format', d.format),
                      _row('Resolution', '${d.width} × ${d.height}'),
                      _row('Size', formatBytes(d.bytes)),
                      _row('Created', _date(d.created)),
                      _row('Modified', _date(d.modified)),
                      _row('Folder', d.folder),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 90,
              child: Text(label, style: const TextStyle(color: Colors.white60)),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(color: Colors.white),
                softWrap: true,
              ),
            ),
          ],
        ),
      );
}
