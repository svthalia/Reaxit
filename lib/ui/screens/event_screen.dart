import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/blocs/event_cubit.dart';
import 'package:reaxit/blocs/registrations_cubit.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/models/event_registration.dart';
import 'package:reaxit/ui/router/router.dart';
import 'package:reaxit/ui/screens/event_admin_screen.dart';
import 'package:reaxit/ui/widgets/error_scroll_view.dart';
import 'package:reaxit/ui/widgets/member_tile.dart';
import 'package:url_launcher/link.dart';

class EventScreen extends StatefulWidget {
  final int pk;
  final Event? event;

  EventScreen({required this.pk, this.event}) : super(key: ValueKey(pk));

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  late final EventCubit _eventCubit;
  late final RegistrationsCubit _registrationsCubit;

  @override
  void initState() {
    final api = RepositoryProvider.of<ApiRepository>(context);
    _eventCubit = EventCubit(api)..load(widget.pk);
    _registrationsCubit = RegistrationsCubit(api)..load(widget.pk);
    super.initState();
  }

  SliverToBoxAdapter _makeMap(Event event) {
    return SliverToBoxAdapter(
      child: Link(
        uri: Uri.parse(
          'https://maps.${Platform.isIOS ? 'apple' : 'google'}.com'
          '/maps?daddr=${Uri.encodeComponent(event.location)}',
        ),
        builder: (context, followLink) => GestureDetector(
          onTap: followLink,
          child: Center(
            child: FadeInImage.assetNetwork(
              // TODO: Replace placeholder with correct size image.
              placeholder: 'assets/img/huygens.jpg',
              image: event.mapsUrl,
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _makeDescription(Event event) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: HtmlWidget(event.description),
      ),
    );
  }

  SliverPadding _makeRegistrations(DetailState<List<EventRegistration>> state) {
    if (state.isLoading) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        sliver: SliverToBoxAdapter(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    } else if (state.hasException) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        sliver: SliverToBoxAdapter(
          child: Center(child: Text(state.message!)),
        ),
      );
    } else {
      return SliverPadding(
        padding: EdgeInsets.all(10),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => MemberTile(
              member: state.result![index].member!,
            ),
            childCount: state.result!.length,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCubit, DetailState<Event>>(
      bloc: _eventCubit,
      builder: (context, state) {
        if (state.hasException) {
          return Scaffold(
            appBar: AppBar(title: Text('Event')),
            body: RefreshIndicator(
              onRefresh: () => _eventCubit.load(widget.pk),
              child: ErrorScrollView(state.message!),
            ),
          );
        } else if (state.isLoading &&
            widget.event == null &&
            state.result == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Event')),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          final event = (state.result ?? widget.event)!;
          return Scaffold(
            appBar: AppBar(
              title: Text('Event'),
              actions: [
                if (event.userPermissions.manageEvent)
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      ThaliaRouterDelegate.of(context).push(
                        MaterialPage(child: EventAdminScreen(pk: event.pk)),
                      );
                    },
                  ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () => _eventCubit.load(widget.pk),
              child: BlocBuilder<RegistrationsCubit,
                  DetailState<List<EventRegistration>>>(
                bloc: _registrationsCubit,
                builder: (context, state) {
                  return CustomScrollView(
                    slivers: [
                      _makeMap(event),
                      // TODO: info
                      // TODO: buttons (with animations)
                      _makeDescription(event),
                      if (event.registrationRequired) _makeRegistrations(state)
                    ],
                  );
                },
              ),
            ),
          );
        }
      },
    );
  }
}
