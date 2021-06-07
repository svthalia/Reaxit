import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/blocs/welcome_cubit.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/models/frontpage_article.dart';
import 'package:reaxit/models/slide.dart';
import 'package:reaxit/ui/router/router.dart';
import 'package:reaxit/ui/screens/calendar_screen.dart';
import 'package:reaxit/ui/widgets/app_bar.dart';
import 'package:reaxit/ui/widgets/error_scroll_view.dart';
import 'package:reaxit/ui/widgets/event_detail_card.dart';
import 'package:reaxit/ui/widgets/menu_drawer.dart';
import 'package:url_launcher/link.dart';
import 'package:collection/collection.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  static final dateFormatter = DateFormat('EEEE d MMMM');

  static Map<DateTime, List<Event>> _groupByDay(List<Event> events) {
    return groupBy<Event, DateTime>(
      events,
      (event) => DateTime(
        event.start.year,
        event.start.month,
        event.start.day,
      ),
    );
  }

  Widget _makeSlides(List<Slide> slides) {
    return AnimatedSize(
      vsync: this,
      curve: Curves.ease,
      duration: Duration(milliseconds: 300),
      child: slides.isNotEmpty ? SlidesCarousel(slides) : SizedBox(height: 0),
    );
  }

  Widget _makeArticle(FrontpageArticle article) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Column(
        children: [
          Text(
            article.title.toUpperCase(),
            style: Theme.of(context).textTheme.subtitle1,
          ),
          HtmlWidget(article.content),
        ],
      ),
    );
  }

  Widget _makeArticles(List<FrontpageArticle> articles) {
    return AnimatedSize(
      vsync: this,
      curve: Curves.ease,
      duration: Duration(milliseconds: 300),
      child: articles.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _makeArticle(articles.first),
                  for (final article in articles.skip(1)) ...[
                    Divider(height: 8),
                    _makeArticle(article),
                  ]
                ],
              ),
            )
          : SizedBox(height: 0),
    );
  }

  Widget _makeUpcomingEvents(List<Event> events) {
    final dayGroupedEvents = _groupByDay(events);
    return AnimatedSize(
      vsync: this,
      curve: Curves.ease,
      duration: Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'UPCOMING EVENTS',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            ...dayGroupedEvents.entries.map<Widget>((entry) {
              final day = entry.key;
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
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
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 6,
                        bottom: 6,
                        top: 10,
                      ),
                      child: Text(
                        dayText,
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                    for (final event in dayEvents)
                      EventDetailCard(event: event),
                  ]);
            }).toList(),
            if (events.isEmpty)
              Padding(
                padding: const EdgeInsets.all(10),
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
      appBar: ThaliaAppBar(title: Text('WELCOME')),
      drawer: MenuDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await BlocProvider.of<WelcomeCubit>(context).load();
        },
        child: BlocBuilder<WelcomeCubit, WelcomeState>(
          builder: (context, state) {
            if (state.hasException) {
              return ErrorScrollView(state.message!);
            } else if (!state.hasResults) {
              return Center(child: CircularProgressIndicator());
            } else {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _makeSlides(state.slides!),
                  if (state.slides!.isNotEmpty)
                    Divider(indent: 16, endIndent: 16, height: 8),
                  _makeArticles(state.articles!),
                  if (state.articles!.isNotEmpty)
                    Divider(indent: 16, endIndent: 16, height: 8),
                  _makeUpcomingEvents(state.upcomingEvents!),
                  TextButton(
                    onPressed: () => ThaliaRouterDelegate.of(context).replace(
                      MaterialPage(child: CalendarScreen()),
                    ),
                    child: Text('SHOW THE ENTIRE AGENDA'),
                  ),
                ],
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

  const SlidesCarousel(
    this.slides, {
    Key? key,
  }) : super(key: key);

  @override
  _SlidesCarouselState createState() => _SlidesCarouselState();
}

class _SlidesCarouselState extends State<SlidesCarousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          options: CarouselOptions(
            disableCenter: true,
            aspectRatio: 1.8,
            viewportFraction: 1,
            autoPlay: true,
            onPageChanged: (index, _) => setState(() {
              _current = index;
            }),
          ),
          itemCount: widget.slides.length,
          itemBuilder: (context, index, _) {
            final slide = widget.slides[index];
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Card(
                elevation: 8,
                child: Link(
                  uri: slide.url,
                  builder: (context, followLink) => InkWell(
                    onTap: followLink,
                    child: FadeInImage.assetNetwork(
                      fit: BoxFit.cover,
                      placeholder: 'assets/img/slide_placeholder.png',
                      image: slide.content.large,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.slides.length,
            (index) => AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: 8.0,
              height: 8.0,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.lerp(
                  Theme.of(context).dividerColor,
                  Colors.grey,
                  _current == index ? 0.5 : 0,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
