import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/models/frontpage_article.dart';
import 'package:reaxit/models/slide.dart';

class WelcomeState extends Equatable {
  /// This can only be null when [isLoading] or [hasException] is true.
  final List<Slide>? slides;

  /// This can only be null when [isLoading] or [hasException] is true.
  final List<FrontpageArticle>? articles;

  /// This can only be null when [isLoading] or [hasException] is true.
  final List<Event>? upcomingEvents;

  /// A message describing why there are no results.
  final String? message;

  /// The results are loading. Existing results may be outdated.
  final bool isLoading;

  bool get hasException => message != null;
  bool get hasResults =>
      slides != null && articles != null && upcomingEvents != null;

  @protected
  const WelcomeState({
    required this.slides,
    required this.articles,
    required this.upcomingEvents,
    required this.isLoading,
    required this.message,
  });

  @override
  List<Object?> get props =>
      [slides, articles, upcomingEvents, message, isLoading];

  WelcomeState copyWith({
    List<Slide>? slides,
    List<FrontpageArticle>? articles,
    List<Event>? upcomingEvents,
    bool? isLoading,
    String? message,
  }) =>
      WelcomeState(
        slides: slides ?? this.slides,
        articles: articles ?? this.articles,
        upcomingEvents: upcomingEvents ?? this.upcomingEvents,
        isLoading: isLoading ?? this.isLoading,
        message: message ?? this.message,
      );

  const WelcomeState.result({
    required List<Slide> this.slides,
    required List<FrontpageArticle> this.articles,
    required List<Event> this.upcomingEvents,
  })  : message = null,
        isLoading = false;

  const WelcomeState.loading({this.slides, this.articles, this.upcomingEvents})
      : message = null,
        isLoading = true;

  const WelcomeState.failure({required String this.message})
      : slides = null,
        articles = null,
        upcomingEvents = null,
        isLoading = false;
}

class WelcomeCubit extends Cubit<WelcomeState> {
  final ApiRepository api;

  WelcomeCubit(this.api) : super(const WelcomeState.loading());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final slidesResponse = await api.getSlides();
      final articlesResponse = await api.getFrontpageArticles();
      final eventsResponse = await api.getEvents(
        start: clock.now(),
        ordering: 'start',
        limit: 3,
      );

      // Filter out SVG slides, as long as concrexit does not offer an alternative.
      final slides = slidesResponse.results
          .where((slide) => !Uri.parse(slide.content.full).path.endsWith('svg'))
          .toList();

      emit(WelcomeState.result(
        slides: slides,
        articles: articlesResponse.results,
        upcomingEvents: eventsResponse.results,
      ));
    } on ApiException catch (exception) {
      emit(WelcomeState.failure(message: _failureMessage(exception)));
    }
  }

  String _failureMessage(ApiException exception) {
    switch (exception) {
      case ApiException.noInternet:
        return 'Not connected to the internet.';
      default:
        return 'An unknown error occurred.';
    }
  }
}
