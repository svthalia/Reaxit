import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';

typedef GroupState = DetailState<Group>;

class GroupCubit extends Cubit<GroupState> {
  final ApiRepository api;

  // By PK
  final int? pk;

  // By slug
  final MemberGroupType? groupType;
  final String? slug;

  // Default: init by PK
  GroupCubit(this.api, {required this.pk})
      : groupType = null,
        slug = null,
        super(const LoadingState());

  // Alternative: init by slug
  GroupCubit.bySlug(this.api, {required this.groupType, required this.slug})
      : pk = null,
        super(const LoadingState());

  Future<void> load() async {
    emit(LoadingState.from(state));
    try {
      Group group;
      if (pk != null) {
        group = await api.getGroup(pk: pk!);
      } else {
        group = await api.getBoardGroup(slug: slug!);
      }
      emit(ResultState(group));
    } on ApiException catch (exception) {
      emit(ErrorState(exception.getMessage(
        notFound: 'The group does not exist.',
      )));
    }
  }
}
