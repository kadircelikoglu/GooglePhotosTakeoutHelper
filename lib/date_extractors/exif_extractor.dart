import 'dart:io';

import 'package:exif/exif.dart';
import 'package:mime/mime.dart';

const int maxFileSize = 32 * 1024 * 1024; // 32 MiB

Future<DateTime?> exifExtractor(File file) async {
  // Check if the file is an image and its size is within the limit
  if (!(lookupMimeType(file.path)?.startsWith('image/') ?? false) || await file.length() > maxFileSize) {
    return null;
  }

  // Read the file bytes
  final bytes = await file.readAsBytes();

  // Extract EXIF tags from the bytes
  final tags = await readExifFromBytes(bytes);

  // Attempt to retrieve the datetime from various EXIF tags
  String? datetime = tags['Image DateTime']?.printable ?? tags['EXIF DateTimeOriginal']?.printable ?? tags['EXIF DateTimeDigitized']?.printable;
  if (datetime == null) {
    return null;
  }

  // Normalize the datetime string
  datetime = datetime
      .replaceAll(RegExp(r'[-/\\.]'), ':') // Replace all separators with ':'
      .replaceAll(': ', ':0') // Handle space followed by ':'
      .substring(0, datetime.length < 19 ? datetime.length : 19) // Trim to 19 chars
      .replaceFirst(':', '-') // Replace first ':' with '-' for ISO compliance
      .replaceFirst(':', '-'); // Replace second ':' with '-' for ISO compliance

  // Parse the normalized datetime string
  return DateTime.tryParse(datetime);
}
