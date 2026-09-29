import 'package:flutter_test/flutter_test.dart';
import 'package:filament_os/features/filaments/domain/filament.dart';
import 'package:filament_os/features/filaments/domain/filament_color.dart';
import 'package:filament_os/features/filaments/domain/filament_type.dart';
import 'package:filament_os/shared/domain/money.dart';
import 'package:filament_os/shared/domain/weight.dart';

void main() {
  group('Campos String vazios', () {
    test('Lançar exceção ao criar Filamento com id vazio', () {
      expect(
        () => Filament(
          id: '',
          name: 'nome',
          ownerId: 'ownerId',
          color: FilamentColor.blue,
          type: FilamentType.pla,
          diameterInMms: 1.75,
          weightInGrams: Weight(weightInMilligrams: 10000000),
          totalCost: Money(amountInCents: 5000, currency: 'EUR'),
        ),
        throwsArgumentError,
      );
    });

    test('Lançar exceção ao criar Filamento com name vazio', () {
      expect(
        () => Filament(
          id: 'id',
          name: '',
          ownerId: 'ownerId',
          color: FilamentColor.blue,
          type: FilamentType.pla,
          diameterInMms: 1.75,
          weightInGrams: Weight(weightInMilligrams: 10000000),
          totalCost: Money(amountInCents: 5000, currency: 'EUR'),
        ),
        throwsArgumentError,
      );
    });

    test('Lançar exceção ao criar Filamento com ownerId vazio', () {
      expect(
        () => Filament(
          id: 'id',
          name: 'nome',
          ownerId: '',
          color: FilamentColor.blue,
          type: FilamentType.pla,
          diameterInMms: 1.75,
          weightInGrams: Weight(weightInMilligrams: 10000000),
          totalCost: Money(amountInCents: 5000, currency: 'EUR'),
        ),
        throwsArgumentError,
      );
    });
  });

  group('Diâmetro inválido', () {
    test('Lançar exceção ao criar Filamento com diâmetro negativo', () {
      expect(
        () => Filament(
          id: 'id',
          name: 'nome',
          ownerId: 'ownerId',
          color: FilamentColor.blue,
          type: FilamentType.pla,
          diameterInMms: -1.75,
          weightInGrams: Weight(weightInMilligrams: 10000000),
          totalCost: Money(amountInCents: 5000, currency: 'EUR'),
        ),
        throwsArgumentError,
      );
    });

    test('Lançar exceção ao criar Filamento com diâmetro zero', () {
      expect(
        () => Filament(
          id: 'id',
          name: 'nome',
          ownerId: 'ownerId',
          color: FilamentColor.blue,
          type: FilamentType.pla,
          diameterInMms: 0,
          weightInGrams: Weight(weightInMilligrams: 10000000),
          totalCost: Money(amountInCents: 5000, currency: 'EUR'),
        ),
        throwsArgumentError,
      );
    });
  });

  test('Lançar exceção ao criar Filamento com totalCost negativo', () {
    expect(
      () => Filament(
        id: 'id',
        name: 'nome',
        ownerId: 'ownerId',
        color: FilamentColor.blue,
        type: FilamentType.pla,
        diameterInMms: 1.75,
        weightInGrams: Weight(weightInMilligrams: 10000000),
        totalCost: Money(amountInCents: -5000, currency: 'EUR'),
      ),
      throwsArgumentError,
    );
  });

  test(
    'Verificar se dois objetos diferentes são considerados diferentes pelo Equatable',
    () {
      final filament1 = Filament(
        id: 'id',
        name: 'name',
        ownerId: 'ownerId',
        color: FilamentColor.blue,
        type: FilamentType.petg,
        diameterInMms: 1.75,
        weightInGrams: Weight.fromGrams(weightInGrams: 200),
        totalCost: Money(amountInCents: 10000, currency: 'EUR'),
      );
      final filament2 = filament1.consumeGrams(
        Weight.fromGrams(weightInGrams: 100),
      );
      expect(filament1 == filament2, false);
    },
  );
}
