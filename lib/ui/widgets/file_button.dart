import 'package:flutter/material.dart';
import 'package:reaxit/utilities/cache_manager.dart';
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
        var file = (await ThaliaCacheManager().getSingleFile(path, key: name));

        file = await ThaliaCacheManager()
            .putFile(path, file.readAsBytesSync(), fileExtension: extension);

        await ThaliaCacheManager().removeFile(name);

        OpenFile.open(file.path);
      },
      icon: const Icon(Icons.description),
      label: Text(name),
    );
  }
}
