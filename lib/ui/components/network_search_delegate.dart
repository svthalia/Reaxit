import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/providers/api_service.dart';

class NetworkSearchDelegate<T extends ApiSearchService> extends SearchDelegate {
  final Widget Function(BuildContext, List<dynamic>, Widget) resultBuilder;
  final Widget Function(BuildContext, List<dynamic>, String, Widget)
      suggestionBuilder;

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
        Widget content;
        switch (service.status) {
          case ApiStatus.NO_INTERNET:
            content = _showError('Not connected to internet.');
            break;
          case ApiStatus.NOT_AUTHENTICATED:
            content = _showError('You are not authenticated.');
            break;
          case ApiStatus.UNKNOWN_ERROR:
            content = _showError('An unknown error occurred.');
            break;
          default:
            content = FutureBuilder(
              future: service.search(query),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.isEmpty) {
                    return _showError("No results");
                  } else {
                    return resultBuilder(context, snapshot.data, child);
                  }
                } else if (snapshot.hasError) {
                  return _showError(snapshot.error);
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            );
        }
        return content;
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Consumer<T>(
      builder: (context, service, child) {
        Widget content;
        switch (service.status) {
          case ApiStatus.NO_INTERNET:
            content = _showError('Not connected to internet.');
            break;
          case ApiStatus.NOT_AUTHENTICATED:
            content = _showError('You are not authenticated.');
            break;
          case ApiStatus.UNKNOWN_ERROR:
            content = _showError('An unknown error occurred.');
            break;
          default:
            content = FutureBuilder(
              future: service.search(query),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.isEmpty) {
                    return _showError("No results");
                  } else {
                    return suggestionBuilder != null
                        ? suggestionBuilder(
                            context, snapshot.data, query, child)
                        : resultBuilder(context, snapshot.data, child);
                  }
                } else if (snapshot.hasError) {
                  return _showError(snapshot.error);
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            );
        }
        return content;
      },
    );
  }

  Widget _showError(String message) {
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
            Text(message),
          ],
        ),
      ),
    );
  }
}
