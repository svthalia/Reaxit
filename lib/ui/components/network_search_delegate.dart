import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/providers/api_service.dart';

// TODO: Maybe we can things better by having the search (optionally) only be executed on query changes. That way, we do less requests, and can eliminate some problems with statful widgets inside search. We would need to listen for query changes, and store the search future.
class NetworkSearchDelegate<T extends ApiService> extends SearchDelegate {
  final Widget Function(BuildContext context, T service, List<dynamic> list)
      resultBuilder;
  final Widget Function(
          BuildContext context, T service, List<dynamic> list, String query)
      suggestionBuilder;
  final Future<List<dynamic>> Function(T service, String query) search;

  /// Creates a [SearchDelegate] that uses [search] to get results.
  ///
  /// [search] can use its [ApiService] argument to search.]
  /// The [resultBuilder] is used to show results. You can optionally specify a
  /// [suggestionBuilder] to show something else while the user is typing a query.
  /// Otherwise, the [resultBuilder] is also applied while the user is typing.
  NetworkSearchDelegate({
    @required this.resultBuilder,
    @required this.search,
    this.suggestionBuilder,
  });

  @override
  ThemeData appBarTheme(BuildContext context) {
    return super
        .appBarTheme(context)
        .copyWith(primaryColor: Theme.of(context).cardColor);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    if (query.isNotEmpty) {
      return <Widget>[
        IconButton(
          tooltip: "Clear search bar",
          icon: Icon(Icons.delete),
          onPressed: () {
            query = "";
          },
        )
      ];
    } else {
      return null;
    }
  }

  @override
  Widget buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return Consumer<T>(
      builder: (context, service, child) {
        return FutureBuilder(
          future: search(service, query),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.isEmpty) {
                return _showError("No results...");
              } else {
                return resultBuilder(context, service, snapshot.data);
              }
            } else if (snapshot.hasError) {
              return _showError(_errorText(snapshot.error));
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Consumer<T>(
      builder: (context, service, child) {
        return FutureBuilder(
          future: search(service, query),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.isEmpty) {
                return _showError("No results...");
              } else {
                return suggestionBuilder != null
                    ? suggestionBuilder(context, service, snapshot.data, query)
                    : resultBuilder(context, service, snapshot.data);
              }
            } else if (snapshot.hasError) {
              return _showError(_errorText(snapshot.error));
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        );
      },
    );
  }

  Widget _showError(String text) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 150,
              margin: const EdgeInsets.all(10),
              child:
                  Image.asset('assets/img/sad_cloud.png', fit: BoxFit.fitWidth),
            ),
            Text(text),
          ],
        ),
      ),
    );
  }

  String _errorText(ApiException error) {
    switch (error) {
      case ApiException.noInternet:
        return 'Not connected to the internet.';
      case ApiException.notAllowed:
        return 'You are not authorized.';
      case ApiException.notFound:
        return 'Not found.';
      case ApiException.notLoggedIn:
        return 'You are not logged in.';
      default:
        return 'An unknown error occured.';
    }
  }
}
