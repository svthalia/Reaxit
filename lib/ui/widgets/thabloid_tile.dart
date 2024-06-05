import 'package:flutter/material.dart';
import 'package:reaxit/models/thabliod.dart';
import 'package:reaxit/ui/widgets/cached_image.dart';
import 'package:url_launcher/url_launcher.dart';

class ThabloidDetailCard extends StatelessWidget {
  final Thabloid thabloid;

  const ThabloidDetailCard(this.thabloid);

  void _openThabloid() {
    launchUrl(Uri.parse(thabloid.file), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Stack(
      children: [
        CachedImage(
          placeholder: 'assets/img/thabloid_placeholder.png',
          imageUrl: thabloid.cover,
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${thabloid.year}-${thabloid.year + 1} nr. ${thabloid.issue}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium?.copyWith(shadows: [
                const Shadow(
                  offset: Offset(0.0, 0.0),
                  blurRadius: 10.0,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ]),
            ),
          ),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openThabloid,
            ),
          ),
        ),
      ],
    );
  }
}
