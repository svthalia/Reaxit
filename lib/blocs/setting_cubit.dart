
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/models/setting.dart';

import 'detail_state.dart';

class SettingCubit extends Cubit<DetailState<Setting>> {
  SettingCubit(DetailState<Setting> initialState) : super(initialState);

}