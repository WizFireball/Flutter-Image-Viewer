import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:path/path.dart' as p;

class ImageDetails {
  final String name, folder, format;
  final int width, height, bytes;
  final DateTime created, modified;

  const ImageDetails({
    required this.name,
    required this.folder,
    required this.format,
    required this.width,
    required this.height,
    required this.bytes,
    required this.created,
    required this.modified,
  });
}

// NOTE : FOR MY FUTURE SELF
// I am not using this low-level code to load these details from
// image directly beacuse either they not able to fetch the 
// orignal details or Consuming double the RAM for single image
// by decoding the loaded image to fetch these deatils

// This low-level code is little hard to understand but
// it consume lesses RAM by not decoding the image and just
// loading the image file as bytes onto RAM and fecthing detials
// directly


Future<ImageDetails> loadImageDetails(String filePath) async {
  final file = File(filePath);
  final stat = await file.stat();

  // This will give you a List of Unsignd 8 byte Integer
  final data = await file.readAsBytes();

  // Reads width/height from the header without fully dicoding the image
  final buffer = await ui.ImmutableBuffer.fromUint8List(data);
  final descriptor = await ui.ImageDescriptor.encoded(buffer);
  final w = descriptor.width;
  final h = descriptor.height;

  // both no longer neded so free up the space
  descriptor.dispose();
  buffer.dispose();

  return ImageDetails(
    name: p.basename(filePath),
    folder: p.dirname(filePath),
    format: _sniffFormat(data, p.extension(filePath)),
    width: w,
    height: h,
    bytes: stat.size,
    // On Windows this is the real creation time; on macOS/Linux Dart only
    // exposes the last metadata change.
    created: stat.changed,
    modified: stat.modified,
  );
}

// Detect the real format from the first bytes
// (a ".jpg" file can actually be a PNG)
// This problem i was talking about earlier in the comments above

String _sniffFormat(Uint8List b, String ext) {

  // Takes that raw List of Bytes (your file)

  bool starts(List<int> sig) {
    if (b.length < sig.length) return false;
    for (var i = 0; i < sig.length; i++) {
      if (b[i] != sig[i]) return false;
    }
    return true;
  }

  // i should used some high-level things instead of this low-level
  // comment for future me
  // you just reading starting bytes to get the extension of file
  // instead of loading the whole file
  if (starts([0xFF, 0xD8, 0xFF])) return 'JPEG';
  if (starts([0x89, 0x50, 0x4E, 0x47])) return 'PNG';
  if (starts([0x47, 0x49, 0x46])) return 'GIF';
  if (starts([0x42, 0x4D])) return 'BMP';
  if (starts([0x52, 0x49, 0x46, 0x46]) &&
      b.length > 11 &&
      String.fromCharCodes(b.sublist(8, 12)) == 'WEBP') {
    return 'WebP';
  }
  return ext.replaceFirst('.', '').toUpperCase();
}

String formatBytes(int b) {

  if (b < 1024) return '$b B';
  if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(1)} KB';
  return '${(b / 1024 / 1024).toStringAsFixed(2)} MB';
}
