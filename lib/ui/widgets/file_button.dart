import 'package:flutter/material.dart';
import 'package:reaxit/utilities/cache_manager.dart';
import 'package:open_file_plus/open_file_plus.dart';

class FileButton extends StatelessWidget {
  final Uri url;
  final String name;
  final String extension;

  FileButton({
    required String url,
    required this.name,
  })  : extension = Uri.parse(url).path.split('.').last,
        url = Uri.parse(url);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        var file = (await ThaliaCacheManager()
                .getFileFromCache('${url.origin}${url.path}'))
            ?.file;

        if (file == null) {
          var newFile = await ThaliaCacheManager()
              .downloadFile(url.toString(), key: name);
          file = await ThaliaCacheManager().putFile(
              '${url.origin}${url.path}', await newFile.file.readAsBytes(),
              fileExtension: extension);

          await ThaliaCacheManager().removeFile(name);
        }

        OpenFile.open(file.path);
      },
      icon: const Icon(Icons.description),
      label: Text(name),
    );
  }
}
