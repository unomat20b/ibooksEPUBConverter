import 'dart:typed_data';

import 'epub_models.dart';

Future<List<EpubInputPackage>> pickEpubDirectoryPackages() async => const [];

void downloadBytes({
  required String fileName,
  required Uint8List bytes,
  required String mimeType,
}) {
  throw UnsupportedError('Download is only available in the browser build.');
}
