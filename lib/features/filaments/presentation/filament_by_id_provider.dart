import 'package:filament_os/features/filaments/domain/filament.dart';
import 'package:filament_os/features/filaments/presentation/filaments_list_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final filamentByIdProvider = Provider.autoDispose.family<AsyncValue<Filament?>, String>((
  ref,
  filamentId,
) {
  return ref.watch(filamentsListProvider).whenData((data) {
    final index = data.indexWhere((e) => e.id == filamentId);
    if (index == -1) return null;
    return data[index];
  });
});
