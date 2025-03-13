import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/models/thabliod.dart';

class ThabloidCubit extends Cubit<Thabloid> {
  final ApiRepository api;
  Thabloid thabloid;
  Timer _debounceTimer = Timer(const Duration(hours: 1), () => {});

  ThabloidCubit(this.api, this.thabloid) : super(thabloid);

  Future<void> load() async {
    emit(thabloid);
  }

  Future<String> getTitle() async {
    if (!_debounceTimer.isActive) {
      Thabloid thabloid = await api.getThabloid(pk: this.thabloid.pk);
      emit(thabloid);
      _debounceTimer = Timer(const Duration(hours: 1), () => {});
    }
    return thabloid.file;
  }
}
