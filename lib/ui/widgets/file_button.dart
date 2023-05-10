import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:reaxit/utilities/cache_manager.dart' as cache;
import 'package:reaxit/config.dart' as config;
import 'package:open_file_plus/open_file_plus.dart';

class FileButton extends StatelessWidget {
  final String path;
  final String name;
  final String extension;

  FileButton({
    required this.path,
    required this.name,
  }) : extension = Uri.parse(path).path.split('.').last;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        var file =
            (await cache.ThaliaCacheManager().getSingleFile(path, key: name));

        file = await cache.ThaliaCacheManager()
            .putFile(path, file.readAsBytesSync(), fileExtension: extension);

        await cache.ThaliaCacheManager().removeFile(name);

        OpenFile.open(file.path);
      },
      icon: const Icon(Icons.description),
      label: Text(name),
    );
  }
}
