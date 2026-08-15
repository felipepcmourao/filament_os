import 'dart:async';

import 'package:filament_os/features/filaments/data/filaments_repository_provider.dart';
import 'package:filament_os/features/filaments/domain/filament.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilamentsListNotifier extends AsyncNotifier<List<Filament>> {
  @override
  FutureOr<List<Filament>> build() async {
    return ref.watch(filamentsRepositoryProvider).list();
  }

  Future<void> addFilament(Filament filament) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(filamentsRepositoryProvider);
      await repo.add(filament);
      final data = await repo.list();
      return data;
    });
  }

  Future<void> removeFilament(String filamentId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(filamentsRepositoryProvider);
      await repo.remove(filamentId);
      final data = await repo.list();
      return data;
    });
  }
}

final filamentsListProvider =
    AsyncNotifierProvider<FilamentsListNotifier, List<Filament>>(
      FilamentsListNotifier.new,
    );
