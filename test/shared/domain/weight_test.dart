import 'package:filament_os/shared/domain/weight.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Lançar exceção ao subtrair além do disponível', () {
    final weight1 = Weight(weightInMilligrams: 2000);
    final weight2 = Weight(weightInMilligrams: 3000);
    expect(() => weight1 - weight2, throwsArgumentError);
  });
}
