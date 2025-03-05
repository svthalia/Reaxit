import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:reaxit/models/vacancie.dart';
import 'package:url_launcher/url_launcher.dart';

class VacancieCard extends StatefulWidget {
  final Vacancy vacancie;

  const VacancieCard({required this.vacancie});

  @override
  VacancieCardState createState() => VacancieCardState();
}

class VacancieCardState extends State<VacancieCard> {
  bool isExpanded = false;

  VacancieCardState();

  void toggleOpen() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  void openVacancie(BuildContext context) {
    if (widget.vacancie.link != '') {
      launchUrl(
        Uri.parse(widget.vacancie.link),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget title = Text(
      widget.vacancie.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    );
    final Widget companyName = Text(
      widget.vacancie.companyname,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium!.copyWith(color: Colors.white.withOpacity(0.8)),
    );

    final Widget expandedChild = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title,
        companyName,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.vacancie.companylogo != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Image.network(widget.vacancie.companylogo!.full),
                ),
              ),
          ],
        ),
        HtmlWidget(widget.vacancie.description),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: ElevatedButton(
            onPressed: () => openVacancie(context),
            child: const Text('MORE INFO'),
          ),
        ),
      ],
    );
    final Widget unexpandedChild = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [title, companyName],
    );

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
      child: InkWell(
        onTap: () => toggleOpen(),
        // Prevent painting ink outside of the card.
        borderRadius: BorderRadius.circular(1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: AnimatedCrossFade(
            key: ObjectKey(widget.vacancie),
            duration: const Duration(milliseconds: 100),
            firstChild: expandedChild,
            secondChild: unexpandedChild,
            crossFadeState:
                isExpanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
          ),
        ),
      ),
    );
  }
}
