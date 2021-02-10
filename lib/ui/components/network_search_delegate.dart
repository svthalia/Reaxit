import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/providers/api_service.dart';

class NetworkSearchDelegate<T extends ApiSearchService> extends SearchDelegate {
  final Widget Function(BuildContext, List<dynamic>, Widget) resultBuilder;
  final Widget Function(BuildContext, List<dynamic>, String, Widget)
      suggestionBuilder;

  /// Creates a [SearchDelegate] that uses an [ApiSearchService]'s [search()]
  /// method.
  ///
  /// The [resultBuilder] is used to show results. You can optionally specify a
  /// [suggestionBuilder] to show something else while the user is typing a query.
  /// Otherwise, the [resultBuilder] is also applied while the user is typing.
  NetworkSearchDelegate({@required this.resultBuilder, this.suggestionBuilder});

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
          future: service.search(query),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.isEmpty) {
                return _showError("No results...");
              } else {
                return resultBuilder(context, snapshot.data, child);
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
          future: service.search(query),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.isEmpty) {
                return _showError("No results...");
              } else {
                return suggestionBuilder != null
                    ? suggestionBuilder(context, snapshot.data, query, child)
                    : resultBuilder(context, snapshot.data, child);
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
        return 'You are not authenticated.';
      case ApiException.notFound:
        return 'Not found.';
      case ApiException.notLoggedIn:
        return 'You are not logged in.';
      default:
        return 'An unknown error occured.';
    }
  }
}
