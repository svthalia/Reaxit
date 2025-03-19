import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/models/thabliod.dart';

class ThabloidCubit extends Cubit<Thabloid> {
  static const Duration maxAge = Duration(hours: 1);

  final ApiRepository api;
  Thabloid thabloid;

  ThabloidCubit(this.api, this.thabloid) : super(thabloid);

  Future<void> load() async {
    emit(thabloid);
  }

  Future<String> getFile() async {
    if (DateTime.now().difference(thabloid.retreivedAt) > maxAge) {
      Thabloid thabloid = await api.getThabloid(pk: this.thabloid.pk);
      emit(thabloid);
    }
    return thabloid.file;
  }
}
