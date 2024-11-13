import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/routes.dart';
import 'package:reaxit/ui/widgets.dart';
import 'package:collection/collection.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  static final dateFormatter = DateFormat('EEEE d MMMM');

  static Map<DateTime, List<BaseEvent>> _groupByDay(List<BaseEvent> events) {
    return groupBy<BaseEvent, DateTime>(
      events,
      (event) => DateTime(event.start.year, event.start.month, event.start.day),
    );
  }

  Widget _makeAnnouncement() {
    return Column(
      children: [
        Announcement(
          'You don\'t have a profile picture yet! Upload one on your profile page by clicking this banner, so that the other members know who you are. :)',
          false,
          'member',
        ),
        Announcement('This is the second announcement', true, 'calendar'),
      ],
    );
  }

  Widget _makeSlides(List<Slide> slides) {
    return AnimatedSize(
      curve: Curves.ease,
      duration: const Duration(milliseconds: 300),
      child:
          slides.isNotEmpty ? SlidesCarousel(slides) : const SizedBox.shrink(),
    );
  }

  Widget _makeArticle(FrontpageArticle article) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text(
            article.title.toUpperCase(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          HtmlWidget(
            article.content,
            onTapUrl: (String url) async {
              Uri uri = Uri(path: url);
              if (uri.scheme.isEmpty) uri = uri.replace(scheme: 'https');
              if (isDeepLink(uri)) {
                context.go(Uri(path: uri.path, query: uri.query).toString());
                return true;
              } else {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (_) {
                  messenger.showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text('Could not open "$url".'),
                    ),
                  );
                }
                return true;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _makeArticles(List<FrontpageArticle> articles) {
    return AnimatedSize(
      curve: Curves.ease,
      duration: const Duration(milliseconds: 300),
      child:
          articles.isNotEmpty
              ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _makeArticle(articles.first),
                    for (final article in articles.skip(1)) ...[
                      const Divider(height: 8),
                      _makeArticle(article),
                    ],
                  ],
                ),
              )
              : const SizedBox.shrink(),
    );
  }

  Widget _makeUpcomingEvents(List<BaseEvent> events) {
    final dayGroupedEvents = _groupByDay(events);
    return AnimatedSize(
      curve: Curves.ease,
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'UPCOMING EVENTS',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ...dayGroupedEvents.entries.map<Widget>((entry) {
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final day = entry.key;
              final dayEvents = entry.value;
              String dayText;
              switch (day.difference(today).inDays) {
                case 0:
                  dayText = 'TODAY';
                  break;
                case 1:
                  dayText = 'TOMORROW';
                  break;
                default:
                  dayText = dateFormatter.format(day).toUpperCase();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    dayText,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  for (final event in dayEvents) EventDetailCard(event: event),
                ],
              );
            }),
            if (events.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'There are no upcoming events.',
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThaliaAppBar(title: const Text('WELCOME')),
      drawer: MenuDrawer(),
      body: RefreshIndicator(
        onRefresh: () => BlocProvider.of<WelcomeCubit>(context).load(),
        child: BlocBuilder<WelcomeCubit, WelcomeState>(
          builder: (context, state) {
            if (state.hasException) {
              return ErrorScrollView(state.message!);
            } else if (!state.hasResults) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Scrollbar(
                child: ListView(
                  key: const PageStorageKey('welcome'),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    _makeSlides(state.slides!),
                    if (state.slides!.isNotEmpty) const Divider(height: 0),
                    _makeArticles(state.articles!),
                    if (state.articles!.isNotEmpty)
                      const Divider(indent: 16, endIndent: 16, height: 8),
                    _makeUpcomingEvents(state.upcomingEvents!),
                    TextButton(
                      onPressed: () => context.goNamed('calendar'),
                      child: const Text('SHOW THE ENTIRE AGENDA'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class SlidesCarousel extends StatefulWidget {
  final List<Slide> slides;

  const SlidesCarousel(this.slides, {super.key});

  @override
  State<SlidesCarousel> createState() => _SlidesCarouselState();
}

class _SlidesCarouselState extends State<SlidesCarousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider.builder(
          options: CarouselOptions(
            aspectRatio: 1075 / 430,
            viewportFraction: 1,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 6),
            onPageChanged:
                (index, _) => setState(() {
                  _current = index;
                }),
          ),
          itemCount: widget.slides.length,
          itemBuilder: (context, index, _) {
            final slide = widget.slides[index];
            return InkWell(
              onTap:
                  slide.url != null
                      ? () async {
                        await launchUrl(
                          slide.url!,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                      : null,
              child: CachedImage(
                imageUrl: slide.content.full,
                placeholder: 'assets/img/slide_placeholder.png',
              ),
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.slides.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(
                  context,
                ).dividerColor.withValues(alpha: _current == index ? 0.6 : 0.4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Announcement extends StatefulWidget {
  String announcement = '';
  bool closable = false;
  String location = '';
  Announcement(this.announcement, this.closable, this.location);

  @override
  State<Announcement> createState() => _AnnouncementState();
}

class _AnnouncementState extends State<Announcement> {
  void navigate(BuildContext context, String location, FullMember me) {
    if (location == 'member') {
      if (me != null) {
        context.pushNamed(
          'member',
          pathParameters: {'memberPk': me.pk.toString()},
          extra: me,
        );
      }
    } else {
      context.goNamed(location);
      // Pop the menu drawer
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FullMemberCubit, FullMemberState>(
      builder: (context, state) {
        if (state.result != null) {
          final me = state.result!;
          return InkWell(
            child: Container(
              color: Theme.of(context).colorScheme.primary,
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.campaign),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: Text(this.widget.announcement),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () => this.navigate(context, this.widget.location, me),
          );
        } else {
          return InkWell(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.campaign),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: Text(this.widget.announcement),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () => {},
          );
        }
      },
    );
  }
}
