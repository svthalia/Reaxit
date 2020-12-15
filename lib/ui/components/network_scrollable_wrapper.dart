import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/providers/api_service.dart';

class NetworkScrollableWrapper<T extends ApiService> extends StatefulWidget {
  final Widget Function(BuildContext, T, Widget) builder;

  NetworkScrollableWrapper({@required this.builder});

  @override
  State<StatefulWidget> createState() => NetWorkScrollableWrapperState<T>();
}

class NetWorkScrollableWrapperState<T extends ApiService>
    extends State<NetworkScrollableWrapper<T>> {
  @override
  Widget build(BuildContext context) {
    return Consumer<T>(builder: (context, service, child) {
      Widget content;
      switch (service.status) {
        case ApiStatus.LOADING:
          content = Center(child: CircularProgressIndicator());
          break;
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
          content = widget.builder(context, service, child);
      }
      return RefreshIndicator(
        onRefresh: () => service.load(),
        child: content,
      );
    });
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
