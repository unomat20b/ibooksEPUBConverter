// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'epub_models.dart';

Future<List<EpubInputPackage>> pickEpubDirectoryPackages() async {
  final input = html.FileUploadInputElement()
    ..multiple = true
    ..style.display = 'none';
  input.setAttribute('webkitdirectory', '');
  input.setAttribute('directory', '');
  html.document.body?.append(input);
  input.click();
  await input.onChange.first;

  final files = input.files ?? const <html.File>[];
  input.remove();
  if (files.isEmpty) return const [];

  final grouped = <String, List<EpubInputFile>>{};
  for (final file in files) {
    final rel = _relativePath(file);
    if (rel.isEmpty) continue;
    final root = rel.split('/').first;
    final bytes = await _readFileBytes(file);
    grouped
        .putIfAbsent(root, () => [])
        .add(EpubInputFile(path: rel, bytes: bytes));
  }

  return [
    for (final entry in grouped.entries)
      EpubInputPackage(
        name: entry.key,
        kind: EpubInputKind.directory,
        files: entry.value,
      ),
  ];
}

void downloadBytes({
  required String fileName,
  required Uint8List bytes,
  required String mimeType,
}) {
  final blob = html.Blob([bytes], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = fileName
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}

String _relativePath(html.File file) {
  final rel = file.relativePath ?? '';
  return rel.isNotEmpty ? rel : file.name;
}

Future<Uint8List> _readFileBytes(html.File file) {
  final reader = html.FileReader();
  final completer = Completer<Uint8List>();
  reader.onError.listen((_) {
    if (!completer.isCompleted) {
      completer.completeError(reader.error ?? StateError('File read failed'));
    }
  });
  reader.onLoadEnd.listen((_) {
    if (completer.isCompleted) return;
    final result = reader.result;
    if (result is ByteBuffer) {
      completer.complete(result.asUint8List());
    } else if (result is Uint8List) {
      completer.complete(result);
    } else {
      completer.completeError(StateError('Unexpected FileReader result'));
    }
  });
  reader.readAsArrayBuffer(file);
  return completer.future;
}
