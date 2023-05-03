import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:reaxit/utilities/cache_manager.dart' as cache;
import 'package:reaxit/config.dart' as config;

class PdfButton extends StatelessWidget {
  final String path;
  final String name;

  const PdfButton({
    required this.path,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        onPressed: () {
          cache.ThaliaCacheManager().downloadFile(path);
        },
        icon: const Icon(Icons.pages),
        label: Text(name));
  }
}
