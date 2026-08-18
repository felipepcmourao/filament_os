import 'package:filament_os/features/prints/data/prints_repository_fake_impl.dart';
import 'package:filament_os/features/prints/domain/prints_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final printsRepositoryProvider = Provider<PrintsRepository>(
  (ref) => PrintsRepositoryFakeImpl(),
);
