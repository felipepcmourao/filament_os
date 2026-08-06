import 'package:filament_os/features/filaments/data/filament_repository_fake_impl.dart';
import 'package:filament_os/features/filaments/domain/filament.dart';
import 'package:filament_os/features/filaments/domain/filament_color.dart';
import 'package:filament_os/features/filaments/domain/filament_not_found_exception.dart';
import 'package:filament_os/features/filaments/domain/filament_type.dart';
import 'package:filament_os/features/prints/data/prints_repository_fake_impl.dart';
import 'package:filament_os/features/prints/domain/print_status.dart';
import 'package:filament_os/features/prints/domain/register_print.dart';
import 'package:filament_os/shared/domain/money.dart';
import 'package:filament_os/shared/domain/weight.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Teste de registro de impressão com mais de um filamento', () async {
    final filamentRepository = FilamentRepositoryFakeImpl();
    final printsRepository = PrintsRepositoryFakeImpl();
    await filamentRepository.add(
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
    await filamentRepository.add(
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
    final print =
        await RegisterPrint(
          filamentRepository: filamentRepository,
          printsRepository: printsRepository,
        ).call(
          printId: 'printId',
          ownerId: 'ownerId',
          status: PrintStatus.successful,
          name: 'name',
          filamentUsage: [
            (filamentId: 'a12', usedGrams: Weight(weightInMiligrams: 1000)),
            (filamentId: 'b23', usedGrams: Weight(weightInMiligrams: 1000)),
          ],
          finalWeight: Weight(weightInMiligrams: 3000),
          printTime: 1.2,
          dateTime: DateTime.now(),
        );

    final printList = await printsRepository.list();

    expect(print.totalCost, Money(amountInCents: 250, currency: 'EUR'));
    expect(printList.last, print);
  });

  test('Teste de registro com filamento inexistente', () async {
    final filamentRepository = FilamentRepositoryFakeImpl();
    final printsRepository = PrintsRepositoryFakeImpl();
    await expectLater(
      () async =>
          await RegisterPrint(
            filamentRepository: filamentRepository,
            printsRepository: printsRepository,
          ).call(
            printId: 'printId',
            ownerId: 'ownerId',
            status: PrintStatus.successful,
            name: 'name',
            filamentUsage: [
              (filamentId: 'a12', usedGrams: Weight(weightInMiligrams: 1000)),
              (filamentId: 'b23', usedGrams: Weight(weightInMiligrams: 1000)),
            ],
            finalWeight: Weight(weightInMiligrams: 3000),
            printTime: 1.2,
            dateTime: DateTime.now(),
          ),
      throwsA(isA<FilamentNotFoundException>()),
    );
  });

  test('Verificar não persistência após falha na validação', () async {
    final filamentRepository = FilamentRepositoryFakeImpl();
    final printsRepository = PrintsRepositoryFakeImpl();

    await filamentRepository.add(
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
    await filamentRepository.add(
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

    await expectLater(
      () async =>
          await RegisterPrint(
            filamentRepository: filamentRepository,
            printsRepository: printsRepository,
          ).call(
            printId: 'printId',
            ownerId: 'ownerId',
            status: PrintStatus.successful,
            name: 'name',
            filamentUsage: [
              (
                filamentId: 'idErrada',
                usedGrams: Weight.fromGrams(weightInGrams: 100),
              ),
              (
                filamentId: 'b23',
                usedGrams: Weight.fromGrams(weightInGrams: 100),
              ),
            ],
            finalWeight: Weight.fromGrams(weightInGrams: 200),
            printTime: 1.2,
            dateTime: DateTime.now(),
          ),
      throwsA(isA<FilamentNotFoundException>()),
    );

    final printsList = await printsRepository.list();
    expect(printsList, isEmpty);
  });
}
