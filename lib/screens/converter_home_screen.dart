import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/epub_converter.dart';
import '../services/epub_models.dart';
import '../services/web_file_io.dart';
import '../widgets/telegram_section_card.dart';

final Uri _boostyDonateUri = Uri.parse('https://boosty.to/daysw/donate');
final Uri _intellectshopProjectsUri = Uri.parse(
  'https://intellectshop.net/projects/',
);

class ConverterHomeScreen extends StatefulWidget {
  const ConverterHomeScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final ThemeMode themeMode;
  final Future<void> Function(ThemeMode) onThemeChanged;

  @override
  State<ConverterHomeScreen> createState() => _ConverterHomeScreenState();
}

class _ConverterHomeScreenState extends State<ConverterHomeScreen> {
  final List<EpubInputPackage> _inputs = [];
  final List<EpubConversionResult> _results = [];
  final List<String> _errors = [];
  bool _converting = false;
  double _progress = 0;

  Future<void> _pickArchives() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const ['epub', 'zip'],
      withData: true,
    );
    if (!mounted || result == null) return;

    final added = <EpubInputPackage>[];
    for (final file in result.files) {
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) continue;
      added.add(
        EpubInputPackage(
          name: file.name,
          kind: EpubInputKind.archive,
          archiveBytes: Uint8List.fromList(bytes),
        ),
      );
    }
    if (added.isEmpty) {
      _showSnack('snack_no_files'.tr());
      return;
    }
    setState(() {
      _inputs.addAll(added);
      _results.clear();
      _errors.clear();
    });
  }

  Future<void> _pickDirectory() async {
    final packages = await pickEpubDirectoryPackages();
    if (!mounted) return;
    if (packages.isEmpty) {
      _showSnack('snack_no_folder'.tr());
      return;
    }
    setState(() {
      _inputs.addAll(packages);
      _results.clear();
      _errors.clear();
    });
  }

  Future<void> _convert() async {
    if (_inputs.isEmpty || _converting) return;
    setState(() {
      _converting = true;
      _progress = 0;
      _results.clear();
      _errors.clear();
    });

    final results = <EpubConversionResult>[];
    final errors = <String>[];
    for (var i = 0; i < _inputs.length; i++) {
      final input = _inputs[i];
      try {
        results.add(EpubConverter.convert(input));
      } on EpubConvertException catch (e) {
        errors.add('${input.name}: ${e.message}');
      } catch (e) {
        errors.add('${input.name}: $e');
      }
      if (!mounted) return;
      setState(() => _progress = (i + 1) / _inputs.length);
      await Future<void>.delayed(const Duration(milliseconds: 30));
    }

    if (!mounted) return;
    setState(() {
      _results.addAll(results);
      _errors.addAll(errors);
      _converting = false;
    });
    if (results.isNotEmpty) {
      _showSnack(
        'snack_converted'.tr(namedArgs: {'count': '${results.length}'}),
      );
    }
  }

  void _download(EpubConversionResult result) {
    downloadBytes(
      fileName: result.outputName,
      bytes: result.bytes,
      mimeType: 'application/epub+zip',
    );
  }

  void _clear() {
    setState(() {
      _inputs.clear();
      _results.clear();
      _errors.clear();
      _progress = 0;
    });
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text('app_title'.tr())),
      drawer: _buildDrawer(context),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        children: [
          TelegramSectionCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.auto_fix_high_outlined,
                    size: 44,
                    color: cs.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'hero_title'.tr(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'hero_text'.tr(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: _converting ? null : _pickDirectory,
                        icon: const Icon(Icons.folder_open_outlined),
                        label: Text('pick_folder'.tr()),
                      ),
                      OutlinedButton.icon(
                        onPressed: _converting ? null : _pickArchives,
                        icon: const Icon(Icons.upload_file_outlined),
                        label: Text('pick_files'.tr()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          TelegramSectionCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.library_books_outlined),
                  title: Text('selected_title'.tr()),
                  subtitle: Text(
                    _inputs.isEmpty
                        ? 'selected_empty'.tr()
                        : 'selected_count'.tr(
                            namedArgs: {'count': '${_inputs.length}'},
                          ),
                  ),
                  trailing: _inputs.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'clear'.tr(),
                          onPressed: _converting ? null : _clear,
                          icon: const Icon(Icons.delete_outline),
                        ),
                ),
                if (_inputs.isNotEmpty) const Divider(height: 1),
                for (final input in _inputs)
                  ListTile(
                    dense: true,
                    leading: Icon(
                      input.kind == EpubInputKind.directory
                          ? Icons.folder_zip_outlined
                          : Icons.description_outlined,
                    ),
                    title: Text(
                      input.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      input.kind == EpubInputKind.directory
                          ? 'input_folder'.tr(
                              namedArgs: {'count': '${input.files.length}'},
                            )
                          : 'input_archive'.tr(),
                    ),
                  ),
              ],
            ),
          ),
          TelegramSectionCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    onPressed: _inputs.isEmpty || _converting ? null : _convert,
                    icon: _converting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.build_circle_outlined),
                    label: Text(
                      _converting ? 'converting'.tr() : 'convert'.tr(),
                    ),
                  ),
                  if (_converting) ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(value: _progress),
                    const SizedBox(height: 8),
                    Text(
                      '${(_progress * 100).round()}%',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_results.isNotEmpty)
            TelegramSectionCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.download_done_outlined),
                    title: Text('results_title'.tr()),
                    subtitle: Text('results_subtitle'.tr()),
                  ),
                  const Divider(height: 1),
                  for (final result in _results)
                    ListTile(
                      title: Text(result.outputName),
                      subtitle: Text(
                        'result_details'.tr(
                          namedArgs: {
                            'files': '${result.fileCount}',
                            'kb': (result.bytes.length / 1024).toStringAsFixed(
                              1,
                            ),
                          },
                        ),
                      ),
                      trailing: FilledButton(
                        onPressed: () => _download(result),
                        child: Text('download'.tr()),
                      ),
                    ),
                ],
              ),
            ),
          if (_errors.isNotEmpty)
            TelegramSectionCard(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.error_outline, color: cs.error),
                    title: Text('errors_title'.tr()),
                    subtitle: Text('errors_subtitle'.tr()),
                  ),
                  const Divider(height: 1),
                  for (final error in _errors)
                    ListTile(dense: true, title: Text(error)),
                ],
              ),
            ),
          TelegramSectionCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'privacy_note'.tr(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  margin: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'app_title'.tr(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ),
                TelegramSectionCard(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.language_outlined),
                        title: Text('language'.tr()),
                        trailing: DropdownButton<Locale>(
                          underline: const SizedBox.shrink(),
                          value: context.locale,
                          items: [
                            DropdownMenuItem(
                              value: const Locale('ru'),
                              child: Text('lang_menu_ru'.tr()),
                            ),
                            DropdownMenuItem(
                              value: const Locale('en'),
                              child: Text('lang_menu_en'.tr()),
                            ),
                          ],
                          onChanged: (locale) {
                            if (locale != null) context.setLocale(locale);
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          widget.themeMode == ThemeMode.system
                              ? Icons.brightness_auto_outlined
                              : widget.themeMode == ThemeMode.dark
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                        ),
                        title: Text('theme'.tr()),
                        trailing: DropdownButton<ThemeMode>(
                          underline: const SizedBox.shrink(),
                          value: widget.themeMode,
                          items: [
                            DropdownMenuItem(
                              value: ThemeMode.system,
                              child: Text('theme_system'.tr()),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.light,
                              child: Text('light_theme'.tr()),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.dark,
                              child: Text('dark_theme'.tr()),
                            ),
                          ],
                          onChanged: (mode) {
                            if (mode != null) widget.onThemeChanged(mode);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                TelegramSectionCard(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: Text('about'.tr()),
                        onTap: () =>
                            _showTextDialog('about'.tr(), 'about_text'.tr()),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.lightbulb_outline),
                        title: Text('tips'.tr()),
                        onTap: () =>
                            _showTextDialog('tips'.tr(), 'tips_text'.tr()),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.volunteer_activism_outlined),
                        title: Text('donate'.tr()),
                        onTap: () => _openUri(_boostyDonateUri),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: TelegramSectionCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(Icons.apps_outlined),
                  title: Text('other_projects'.tr()),
                  subtitle: Text('other_projects_intellectshop'.tr()),
                  trailing: const Icon(Icons.open_in_new, size: 20),
                  onTap: () => _openUri(_intellectshopProjectsUri),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTextDialog(String title, String text) {
    Navigator.pop(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(text)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('ok'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _openUri(Uri uri) async {
    Navigator.pop(context);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted || ok) return;
    _showSnack('donate_error'.tr());
  }
}
