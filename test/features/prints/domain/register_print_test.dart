import 'package:filament_os/features/filaments/data/filament_repository_fake_impl.dart';
import 'package:filament_os/features/filaments/domain/filament.dart';
import 'package:filament_os/features/filaments/domain/filament_color.dart';
import 'package:filament_os/features/filaments/domain/filament_not_found_exception.dart';
import 'package:filament_os/features/filaments/domain/filament_type.dart';
import 'package:filament_os/features/prints/domain/print_status.dart';
import 'package:filament_os/features/prints/domain/register_print.dart';
import 'package:filament_os/shared/domain/money.dart';
import 'package:filament_os/shared/domain/weight.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Teste de registro de impressão com mais de um filamento', () async {
    final repository = FilamentRepositoryFakeImpl();
    await repository.add(
      Filament(
        id: 'a12',
        name: 'name',
        ownerId: 'ownerId',
        color: FilamentColor.blue,
        type: FilamentType.pla,
        diameterInMms: 1.75,
        weightInGrams: Weight(weightInMiligrams: 2000),
        totalCost: Money(amountInCents: 200, currency: 'EUR'),
      ),
    );
    await repository.add(
      Filament(
        id: 'b23',
        name: 'name',
        ownerId: 'ownerId',
        color: FilamentColor.blue,
        type: FilamentType.pla,
        diameterInMms: 1.75,
        weightInGrams: Weight(weightInMiligrams: 2000),
        totalCost: Money(amountInCents: 300, currency: 'EUR'),
      ),
    );
    final print = await RegisterPrint(
      repository: repository,
      printId: 'printId',
      dateTime: DateTime.now(),
      filamentUsage: [
        (filamentId: 'a12', usedGrams: Weight(weightInMiligrams: 1000)),
        (filamentId: 'b23', usedGrams: Weight(weightInMiligrams: 1000)),
      ],
      name: 'name',
      printTime: 1.2,
      finalWeight: Weight(weightInMiligrams: 3000),
      ownerId: 'ownerId',
      status: PrintStatus.successful,
    ).call();

    expect(print.totalCost, Money(amountInCents: 250, currency: 'EUR'));
  });

  test('Teste de registro com filamento inexistente', () async {
    final repository = FilamentRepositoryFakeImpl();
    expect(
      () async => await RegisterPrint(
        repository: repository,
        printId: 'printId',
        dateTime: DateTime.now(),
        filamentUsage: [
          (filamentId: '2222', usedGrams: Weight(weightInMiligrams: 2000)),
        ],
        name: 'name',
        printTime: 1.2,
        finalWeight: Weight(weightInMiligrams: 20000),
        ownerId: 'ownerId',
        status: PrintStatus.successful,
      ).call(),
      throwsA(isA<FilamentNotFoundException>()),
    );
  });
}
