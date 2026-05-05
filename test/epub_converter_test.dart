import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ibooks_epub_converter/services/epub_converter.dart';
import 'package:ibooks_epub_converter/services/epub_models.dart';

void main() {
  test('converts iBooks-style directory package to valid epub zip', () {
    final result = EpubConverter.convert(
      EpubInputPackage(
        name: 'Book.epub',
        kind: EpubInputKind.directory,
        files: [
          EpubInputFile(
            path: 'Book.epub/mimetype',
            bytes: Uint8List.fromList(utf8.encode('application/epub+zip')),
          ),
          EpubInputFile(
            path: 'Book.epub/META-INF/container.xml',
            bytes: Uint8List.fromList(utf8.encode('<container />')),
          ),
          EpubInputFile(
            path: 'Book.epub/OEBPS/chapter.xhtml',
            bytes: Uint8List.fromList(utf8.encode('<html>Text</html>')),
          ),
        ],
      ),
    );

    final archive = ZipDecoder().decodeBytes(result.bytes);

    expect(result.outputName, 'Book - recovered.epub');
    expect(archive.files.first.name, 'mimetype');
    expect(archive.files.first.compression, CompressionType.none);
    expect(
      archive.files.map((file) => file.name),
      contains('META-INF/container.xml'),
    );
    expect(
      archive.files.map((file) => file.name),
      contains('OEBPS/chapter.xhtml'),
    );
  });

  test('rejects packages without container.xml', () {
    expect(
      () => EpubConverter.convert(
        EpubInputPackage(
          name: 'broken.epub',
          kind: EpubInputKind.directory,
          files: [
            EpubInputFile(
              path: 'broken.epub/mimetype',
              bytes: Uint8List.fromList(utf8.encode('application/epub+zip')),
            ),
          ],
        ),
      ),
      throwsA(isA<EpubConvertException>()),
    );
  });
}
