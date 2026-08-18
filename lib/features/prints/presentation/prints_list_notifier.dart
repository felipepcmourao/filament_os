import 'dart:async';

import 'package:filament_os/features/prints/di/prints_repository_provider.dart';
import 'package:filament_os/features/prints/domain/print.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrintsListNotifier extends AsyncNotifier<List<Print>> {
  @override
  FutureOr<List<Print>> build() {
    return ref.watch(printsRepositoryProvider).list();
  }
}

final printsListProvider =
    AsyncNotifierProvider<PrintsListNotifier, List<Print>>(
      PrintsListNotifier.new,
    );
