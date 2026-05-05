import 'dart:typed_data';

enum EpubInputKind { archive, directory }

class EpubInputFile {
  const EpubInputFile({required this.path, required this.bytes});

  final String path;
  final Uint8List bytes;
}

class EpubInputPackage {
  const EpubInputPackage({
    required this.name,
    required this.kind,
    this.archiveBytes,
    this.files = const [],
  });

  final String name;
  final EpubInputKind kind;
  final Uint8List? archiveBytes;
  final List<EpubInputFile> files;
}

class EpubConversionResult {
  const EpubConversionResult({
    required this.sourceName,
    required this.outputName,
    required this.bytes,
    required this.fileCount,
    required this.inputKind,
  });

  final String sourceName;
  final String outputName;
  final Uint8List bytes;
  final int fileCount;
  final EpubInputKind inputKind;
}
