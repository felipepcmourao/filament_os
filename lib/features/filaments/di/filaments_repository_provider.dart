import 'package:filament_os/features/filaments/data/filaments_repository_fake_impl.dart';
import 'package:filament_os/features/filaments/domain/filaments_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final filamentsRepositoryProvider = Provider<FilamentsRepository>(
  (ref) => FilamentsRepositoryFakeImpl(),
);
