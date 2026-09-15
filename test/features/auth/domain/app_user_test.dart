import 'package:filament_os/features/auth/domain/app_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uid vazio lança Argument Error', () {
    expect(() => AppUser(uid: ''), throwsArgumentError);
  });

  test('uid apenas com espaço no corpo lança Argument Error', () {
    expect(() => AppUser(uid: ' '), throwsArgumentError);
  });

  test('dois AppUser com mesmo uid são iguais', () {
    final user1 = AppUser(uid: '001');
    final user2 = AppUser(uid: '001');
    expect(user1, equals(user2));
  });
}
