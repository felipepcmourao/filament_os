import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthNotifier extends Notifier<bool> {
  @override
  bool build() {
    return true;
  }

  void toggle() => state = !state;
}

final authProvider = NotifierProvider<AuthNotifier, bool>(AuthNotifier.new);
