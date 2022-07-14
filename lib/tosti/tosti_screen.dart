import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/tosti/blocs/auth_cubit.dart';
import 'package:reaxit/tosti/blocs/home_cubit.dart';
import 'package:reaxit/tosti/widgets/venue_card.dart';
import 'package:reaxit/ui/widgets/app_bar.dart';
import 'package:reaxit/ui/widgets/error_scroll_view.dart';
import 'package:reaxit/ui/widgets/menu_drawer.dart';

class TostiScreen extends StatelessWidget {
  const TostiScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: ThaliaAppBar(
        title: const Text('T.O.S.T.I.'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => BlocProvider.of<TostiAuthCubit>(context).logOut(),
          ),
        ],
      ),
      drawer: MenuDrawer(),
      body: BlocConsumer<TostiAuthCubit, TostiAuthState>(
        listenWhen: (previous, current) {
          if (previous is LoggedInTostiAuthState &&
              current is LoggedOutTostiAuthState) {
            return true;
          } else if (current is FailureTostiAuthState) {
            return true;
          }
          return false;
        },
        listener: (context, state) async {
          // Show a snackbar when the user logs out or logging in fails.
          if (state is LoggedOutTostiAuthState) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Logged out.'),
            ));
          } else if (state is FailureTostiAuthState) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(state.message ?? 'Logging in failed.'),
            ));
          }
        },
        builder: (context, state) {
          if (state is LoadingTostiAuthState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LoggedInTostiAuthState) {
            return RepositoryProvider.value(
              value: state.apiRepository,
              child: BlocProvider(
                create: (context) => TostiHomeCubit(
                  state.apiRepository,
                )..load(),
                child: const _SignedInTostiHomeView(),
              ),
            );
          } else {
            return Center(
              child: Column(
                children: [
                  const Text('You need to be logged in to use T.O.S.T.I.'),
                  ElevatedButton(
                    onPressed: () => BlocProvider.of<TostiAuthCubit>(
                      context,
                    ).logIn(),
                    child: const Text('LOGIN'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class _SignedInTostiHomeView extends StatelessWidget {
  const _SignedInTostiHomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => BlocProvider.of<TostiHomeCubit>(context).load(),
      child: BlocBuilder<TostiHomeCubit, TostiHomeState>(
        buildWhen: (previous, current) => !current.isLoading,
        builder: (context, state) {
          if (state.isLoading) {
            return const SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          } else if (state.hasException) {
            return ErrorScrollView(state.message!);
          } else if (state.result!.isEmpty) {
            return const ErrorScrollView('There are no venues.');
          } else {
            return Column(
              children: [
                for (final venue in state.result!)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: VenueCard(venue),
                  ),
              ],
            );
          }
        },
      ),
    );
  }
}
