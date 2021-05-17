import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/food_cubit.dart';
import 'package:reaxit/models/food_event.dart';
import 'package:reaxit/ui/widgets/app_bar.dart';
import 'package:reaxit/ui/widgets/error_scroll_view.dart';

class FoodScreen extends StatefulWidget {
  final int pk;
  final FoodEvent? foodEvent;

  FoodScreen({required this.pk, this.foodEvent}) : super(key: ValueKey(pk));

  @override
  _FoodScreenState createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  late final FoodCubit _foodCubit;

  @override
  void initState() {
    _foodCubit = FoodCubit(
      RepositoryProvider.of<ApiRepository>(context),
    )..load(widget.pk);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FoodCubit, FoodState>(
      bloc: _foodCubit,
      builder: (context, state) {
        if (state.hasException) {
          return Scaffold(
            appBar: ThaliaAppBar(
              title: Text('Order Food'),
            ),
            body: ErrorScrollView(state.message!),
          );
        } else if (state.isLoading) {
          return Scaffold(
            appBar: ThaliaAppBar(
              title: Text('Order Food'),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          return Scaffold(
            appBar: ThaliaAppBar(
              title: Text('Order Food'),
            ),
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Center(
                    child: Text(state.foodEvent!.title),
                  ),
                )
              ],
            ),
          );
        }
      },
    );
  }
}
