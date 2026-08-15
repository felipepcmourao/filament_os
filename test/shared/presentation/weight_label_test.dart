import 'package:filament_os/shared/domain/weight.dart';
import 'package:filament_os/shared/presentation/weight_label.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Aparece Sem estoque quando o peso é igual a zero', () {
    final weight = Weight(weightInMiligrams: 0);
    expect(weight.label, 'Sem estoque');
  });

  test('Ignora as casas decimais se o número for um inteiro', () {
    final weight = Weight(weightInMiligrams: 80000);
    expect(weight.label, '80 gramas');
  });

  test('Apresenta duas casas decimais se o número não for inteiro', () {
    final weight = Weight(weightInMiligrams: 29860);
    expect(weight.label, '29,86 gramas');
  });

  test(
    'Valores inteiros terminados em zero não perdem casas ao se tornarem label',
    () {
      final weight = Weight(weightInMiligrams: 100000);
      expect(weight.label, '100 gramas');
    },
  );

  test(
    'Quando o resultado é 1, o texto ainda fica no plural. A ser tratado com intl',
    () {
      final weight = Weight(weightInMiligrams: 1000);
      expect(weight.label, '1 gramas');
    },
  );
}
