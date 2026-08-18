import 'package:filament_os/core/theme/app_theme.dart';
import 'package:filament_os/features/filaments/di/filaments_repository_provider.dart';
import 'package:filament_os/features/filaments/domain/filament.dart';
import 'package:filament_os/features/filaments/domain/filament_color.dart';
import 'package:filament_os/features/filaments/domain/filament_type.dart';
import 'package:filament_os/features/filaments/domain/filaments_repository.dart';
import 'package:filament_os/features/filaments/presentation/filaments_page.dart';
import 'package:filament_os/shared/domain/money.dart';
import 'package:filament_os/shared/domain/weight.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Filaments Page apresenta erro ao listar Filamentos', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        filamentsRepositoryProvider.overrideWith(
          (ref) => FilamentRepositoryForTest1(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: const FilamentsPage(),
          theme: AppTheme.lightTheme,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Falha'), findsOneWidget);
  });

  testWidgets(
    'Filaments Page apresenta lista sem apertar em Adicionar Filamento',
    (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          filamentsRepositoryProvider.overrideWith(
            (ref) => FilamentRepositoryForTest2(),
          ),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: const FilamentsPage(),
            theme: AppTheme.lightTheme,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Filamento Azul'), findsOneWidget);
    },
  );
}

class FilamentRepositoryForTest1 implements FilamentsRepository {
  @override
  Future<List<Filament>> list() async {
    return Future.error(Exception('Falha'));
  }

  @override
  Future<void> add(Filament filament) => throw UnimplementedError();

  @override
  Future<void> remove(String id) => throw UnimplementedError();

  @override
  Future<void> update(Filament filament) => throw UnimplementedError();
}

class FilamentRepositoryForTest2 implements FilamentsRepository {
  @override
  Future<List<Filament>> list() async {
    return [
      Filament(
        id: 'id',
        name: 'Filamento Azul',
        ownerId: 'ownerId',
        color: FilamentColor.blue,
        type: FilamentType.pla,
        diameterInMms: 1.75,
        weightInGrams: Weight(weightInMiligrams: 10000000),
        totalCost: Money(amountInCents: 5000, currency: 'EUR'),
      ),
    ];
  }

  @override
  Future<void> add(Filament filament) => throw UnimplementedError();

  @override
  Future<void> remove(String id) => throw UnimplementedError();

  @override
  Future<void> update(Filament filament) => throw UnimplementedError();
}
