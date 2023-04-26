import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:reaxit/utilities/cache_manager.dart' as cache;
import 'package:reaxit/config.dart' as config;

class PdfButton extends GestureDetector {

  PdfButton({required String path, required String name})
      : super(child: PdfBox(path, name), onTap: () async => PdfViewer.openFile((await cache.cacheManager.getSingleFile(path)).path));

}

class PdfBox extends UnconstrainedBox {

  PdfBox(String path, String name)
}
