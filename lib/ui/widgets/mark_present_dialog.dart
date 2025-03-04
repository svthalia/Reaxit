import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs.dart';

class MarkPresentDialog extends StatefulWidget {
  final int pk;
  final String token;

  MarkPresentDialog({required this.pk, required this.token})
    : super(key: ValueKey(pk));

  @override
  State<MarkPresentDialog> createState() => _MarkPresentDialogState();
}

class _MarkPresentDialogState extends State<MarkPresentDialog> {
  late final MarkPresentCubit _markPresentCubit;

  @override
  void initState() {
    _markPresentCubit = MarkPresentCubit(
      RepositoryProvider.of<ApiRepository>(context),
    )..load(pk: widget.pk, token: widget.token);
    super.initState();
  }

  @override
  void dispose() {
    _markPresentCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarkPresentCubit, MarkPresentState>(
      bloc: _markPresentCubit,
      builder: (context, state) {
        late final Widget content = switch (state) {
          FailureMarkPresentState(message: var message) => Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          LoadingMarkPresentState _ => const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [CircularProgressIndicator()],
          ),
          SuccessMarkPresentState(message: var message) => Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        };

        return AlertDialog(
          title: const Text('Presence'),
          content: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: content,
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              icon: const Icon(Icons.clear),
              label: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }
}
