import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import 'epub_models.dart';

class EpubConvertException implements Exception {
  const EpubConvertException(this.message);

  final String message;

  @override
  String toString() => message;
}

class EpubConverter {
  static EpubConversionResult convert(EpubInputPackage input) {
    final files = _normalizedFiles(input);
    if (files.isEmpty) {
      throw const EpubConvertException('Файлы EPUB не найдены.');
    }

    final mimetype = files['mimetype'];
    if (mimetype == null) {
      throw const EpubConvertException(
        'В пакете нет файла mimetype. Это не похоже на EPUB.',
      );
    }
    final mimetypeText = utf8.decode(mimetype, allowMalformed: true).trim();
    if (mimetypeText != 'application/epub+zip') {
      throw EpubConvertException(
        'Неверный mimetype: "$mimetypeText". Ожидалось application/epub+zip.',
      );
    }
    if (!files.containsKey('META-INF/container.xml')) {
      throw const EpubConvertException(
        'В пакете нет META-INF/container.xml. Невозможно найти OPF.',
      );
    }

    final archive = Archive();
    archive.addFile(
      ArchiveFile.noCompress('mimetype', mimetype.length, mimetype),
    );

    final names = files.keys.where((name) => name != 'mimetype').toList()
      ..sort((a, b) {
        final aw = a.startsWith('META-INF/') ? 0 : 1;
        final bw = b.startsWith('META-INF/') ? 0 : 1;
        if (aw != bw) return aw.compareTo(bw);
        return a.compareTo(b);
      });

    for (final name in names) {
      final data = files[name]!;
      final file = ArchiveFile.bytes(name, data);
      file.compression = CompressionType.deflate;
      file.compressionLevel = 9;
      archive.addFile(file);
    }

    final encoded = ZipEncoder().encode(archive);
    if (encoded.isEmpty) {
      throw const EpubConvertException('Не удалось собрать EPUB-архив.');
    }

    return EpubConversionResult(
      sourceName: input.name,
      outputName: _outputName(input.name),
      bytes: Uint8List.fromList(encoded),
      fileCount: files.length,
      inputKind: input.kind,
    );
  }

  static Map<String, Uint8List> _normalizedFiles(EpubInputPackage input) {
    final rawFiles = input.archiveBytes != null
        ? _filesFromArchive(input.archiveBytes!)
        : input.files;
    final out = <String, Uint8List>{};
    final prefix = _detectRootPrefix(rawFiles);

    for (final file in rawFiles) {
      var path = _cleanPath(file.path);
      if (prefix.isNotEmpty && path.startsWith(prefix)) {
        path = path.substring(prefix.length);
      }
      path = _cleanPath(path);
      if (path.isEmpty ||
          path.endsWith('/') ||
          path.startsWith('__MACOSX/') ||
          path.split('/').any((part) => part == '.DS_Store')) {
        continue;
      }
      out[path] = file.bytes;
    }

    return out;
  }

  static List<EpubInputFile> _filesFromArchive(Uint8List bytes) {
    late final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (_) {
      throw const EpubConvertException(
        'Не удалось прочитать ZIP-структуру EPUB.',
      );
    }

    return [
      for (final file in archive.files)
        if (file.isFile)
          EpubInputFile(
            path: file.name,
            bytes: Uint8List.fromList(file.content),
          ),
    ];
  }

  static String _detectRootPrefix(List<EpubInputFile> files) {
    for (final file in files) {
      final path = _cleanPath(file.path);
      if (path == 'mimetype') return '';
      if (path.endsWith('/mimetype')) {
        return path.substring(0, path.length - 'mimetype'.length);
      }
    }
    return '';
  }

  static String _cleanPath(String raw) {
    var path = raw.replaceAll('\\', '/');
    while (path.startsWith('/')) {
      path = path.substring(1);
    }
    try {
      path = Uri.decodeFull(path);
    } catch (_) {
      // Оставляем исходный путь: часть EPUB встречается с невалидным percent-encoding.
    }
    return path;
  }

  static String _outputName(String sourceName) {
    var name = sourceName.trim();
    if (name.isEmpty) name = 'converted';
    if (name.toLowerCase().endsWith('.epub')) {
      name = name.substring(0, name.length - 5);
    }
    name = name
        .replaceAll(RegExp(r'[\\/:*?"<>|]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (name.isEmpty) name = 'converted';
    return '$name - recovered.epub';
  }
}
