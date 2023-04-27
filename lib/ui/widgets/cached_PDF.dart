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
        onPressed: () async {
          print(path);
          var test = (await cache.ThaliaCacheManager().getSingleFile(
                  'https://cdn.staging.thalia.nu/documents/example.pdf?ResponseContentDisposition=attachment%3B+filename%3D%22annual-report-2021.pdf%22&Expires=1682595182&Signature=BQWWndLzObb5xXQUhv-SuJxgPw1aNo8N~Xe0XkZKWjfA1vRNwKxWQOfcDTNsjrjzDM9bsbbsXeqKW6tGtFv4rPBoKJJ8ocTRTMlTC~WzVhJs5VSFL4GBWQPDRPBHaaqZXldT19zZc7d7CK7i-0cqPshZ2FWadlcc4mGfRmSNtI0bdXPNuduLLKa551MiyQRQNf45p7WJCSCC7xNGeIg5iVJPAXib8cDT2GBYcD57eXHrzHrTBkHeQ6DRS5ESiLRGzqD4NnM0iEG~hpqdbmc67Mx0oKdf3PowLnWZuYK86wpaFzbHY5BbobTWhslCRKQOOlW3khkdXb-Aicn-InYgRA__&Key-Pair-Id=K2R1E6JDIG8U40'))
              .path;
          print(test);
          PdfViewer.openFile(test);
        },
        icon: const Icon(Icons.pages),
        label: Text(name));
  }
}
