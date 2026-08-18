import 'package:filament_os/features/filaments/di/filaments_repository_provider.dart';
import 'package:filament_os/features/prints/di/prints_repository_provider.dart';
import 'package:filament_os/features/prints/domain/register_print.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final registerPrintProvider = Provider<RegisterPrint>((ref) {
  final filamentsRepository = ref.watch(filamentsRepositoryProvider);
  final printsRepository = ref.watch(printsRepositoryProvider);

  return RegisterPrint(
    filamentRepository: filamentsRepository,
    printsRepository: printsRepository,
  );
});
