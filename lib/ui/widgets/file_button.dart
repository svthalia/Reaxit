import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:reaxit/utilities/cache_manager.dart' as cache;
import 'package:reaxit/config.dart' as config;
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class FileButton extends StatelessWidget {
  final String path;
  final String name;

  const FileButton({
    required this.path,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        onPressed: () {
          launchUrlString(path, mode: LaunchMode.externalApplication);
        },
        icon: const Icon(Icons.pages),
        label: Text(name));
  }
}
