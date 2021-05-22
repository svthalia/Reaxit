import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/blocs/group_cubit.dart';
import 'package:reaxit/models/group.dart';
import 'package:reaxit/ui/widgets/app_bar.dart';
import 'package:reaxit/ui/widgets/error_scroll_view.dart';
import 'package:reaxit/ui/widgets/member_tile.dart';

class GroupScreen extends StatefulWidget {
  final int pk;
  final ListGroup? group;

  GroupScreen({required this.pk, this.group}) : super(key: ValueKey(pk));

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  late final GroupCubit _groupCubit;

  @override
  void initState() {
    final api = RepositoryProvider.of<ApiRepository>(context);
    _groupCubit = GroupCubit(api)..load(widget.pk);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupCubit, DetailState<Group>>(
      bloc: _groupCubit,
      builder: (context, state) {
        if (state.hasException) {
          return Scaffold(
            appBar: ThaliaAppBar(title: Text(widget.group?.name ?? 'Group')),
            body: RefreshIndicator(
              onRefresh: () async {
                await _groupCubit.load(widget.pk);
              },
              child: ErrorScrollView(state.message!),
            ),
          );
        } else if (state.isLoading &&
            widget.group == null &&
            state.result == null) {
          // TODO: Determine what can and cannot be shown while loading.
          return Scaffold(
            appBar: ThaliaAppBar(title: Text('Group')),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          final group = (state.result ?? widget.group)!;
          return Scaffold(
            appBar: ThaliaAppBar(
              title: Text(group.name),
            ),
            body: Center(
              child: Text(group.name),
            ),
          );
        }
      },
    );
  }
}
