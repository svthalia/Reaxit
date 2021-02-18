import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/providers/api_service.dart';

class NetworkWrapper<T extends ApiService> extends StatelessWidget {
  final Widget Function(BuildContext context, T service) builder;
  final bool showWhileLoading;

  /// Creates a widget that uses an [ApiService].
  /// The [builder] callback should return a widget to display when the service
  /// is ready. By default, [builder] is used when the service has no error and
  /// is not loading. Set [showWhileLoading] to false to
  NetworkWrapper({@required this.builder, this.showWhileLoading = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<T>(
      builder: (context, service, child) {
        if (!service.isLoading || showWhileLoading) {
          return RefreshIndicator(
            onRefresh: service.load,
            child: builder(context, service),
          );
        } else if (service.hasError) {
          return RefreshIndicator(
            onRefresh: service.load,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  height: 100,
                  margin: const EdgeInsets.all(10),
                  child: Image.asset(
                    'assets/img/sad_cloud.png',
                    fit: BoxFit.fitHeight,
                  ),
                ),
                Text(
                  _errorText(service.error),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
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
